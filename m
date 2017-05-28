From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v2 08/20] randstruct: Whitelist NIU struct page overloading
Date: Sun, 28 May 2017 10:35:34 -0700
Message-ID: <CAGXu5jKTDs=1gU_QQjkHFr_XWF0vZgCDrtYHOjm0i1k1Kn8uKA@mail.gmail.com>
References: <1495829844-69341-1-git-send-email-keescook@chromium.org>
 <1495829844-69341-9-git-send-email-keescook@chromium.org> <20170528081541.GE22193@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	"David S . Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>,
	"x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>, linux-mm@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>
Return-path: <kernel-hardening-return-8093-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Sender: keescook@google.com
In-Reply-To: <20170528081541.GE22193@infradead.org>
List-Id: netdev.vger.kernel.org

On Sun, May 28, 2017 at 1:15 AM, Christoph Hellwig <hch@infradead.org> wrot=
e:
> On Fri, May 26, 2017 at 01:17:12PM -0700, Kees Cook wrote:
>> The NIU ethernet driver intentionally stores a page struct pointer on
>> top of the "mapping" field. Whitelist this case:
>>
>> drivers/net/ethernet/sun/niu.c: In function =E2=80=98niu_rx_pkt_ignore=
=E2=80=99:
>> drivers/net/ethernet/sun/niu.c:3402:10: note: found mismatched ssa struc=
t pointer types: =E2=80=98struct page=E2=80=99 and =E2=80=98struct address_=
space=E2=80=99
>>
>>     *link =3D (struct page *) page->mapping;
>>     ~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>
> The driver really needs to stop doing this anyway.  It would be good
> to send this out to linux-mm and netdev to come up with a better scheme.

Added to To. :) I couldn't understand why it was doing what it was
doing, hence the whitelist entry.

-Kees

--=20
Kees Cook
Pixel Security
