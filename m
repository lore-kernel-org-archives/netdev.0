From: "PaX Team" <pageexec@freemail.hu>
Subject: Re: [PATCH v2] mac80211: LLVMLinux: Remove VLAIS usage from mac80211
Date: Sat, 08 Mar 2014 23:01:48 +0100
Message-ID: <531B934C.31666.37555A14@pageexec.freemail.hu>
References: <1394177091.4653.1.camel@jlt4.sipsolutions.net>, <1394241960-1764-1-git-send-email-behanw@converseincode.com>, <CABikg9y_j-SDOsMj1C5uogP0HNj6bsB_ySVFtAh_oNgZ0swd=g@mail.gmail.com>
Reply-To: pageexec@freemail.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linville@tuxdriver.com, johannes@sipsolutions.net,
	davem@davemloft.net,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dwmw2@infradead.org,
	"=?UTF-8?Q?Jan-Simon_M=C3=B6ller?=" <dl9pf@gmx.de>,
	"=?UTF-8?Q?Vin=C3=ADcius_Tinti?=" <viniciustinti@gmail.com>,
	Mark Charlebois <charlebm@gmail.com>
To: behanw@converseincode.com, Sergei Antonov <saproj@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <CABikg9y_j-SDOsMj1C5uogP0HNj6bsB_ySVFtAh_oNgZ0swd=g@mail.gmail.com>
Content-description: Mail message body
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8 Mar 2014 at 21:29, Sergei Antonov wrote:

> > -       memset(&aead_req, 0, sizeof(aead_req));
> > +       char aead_req_data[sizeof(struct aead_request) +
> > +                               crypto_aead_reqsize(tfm) +
> > +                               CRYPTO_MINALIGN] CRYPTO_MINALIGN_ATTR;
                                                     ^^^^^^^^^^^^^^^^^^^^
wouldn't the underlined attribute ensure the required alignment?

> Bad trick with regards to alignment.
> The alignment requirement for struct aead_request is stronger than
> what an array of chars may have.
