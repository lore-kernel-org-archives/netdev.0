From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Question on rhashtable in worst-case scenario.
Date: Wed, 30 Mar 2016 11:14:12 +0200
Message-ID: <1459329252.2055.1.camel@sipsolutions.net>
References: <56F9941A.3080501@candelatech.com>
	 <56FAAA6D.3070806@candelatech.com> (sfid-20160329_181708_555021_6CC5B70B)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>
To: Ben Greear <greearb@candelatech.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56FAAA6D.3070806@candelatech.com> (sfid-20160329_181708_555021_6CC5B70B)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-03-29 at 09:16 -0700, Ben Greear wrote:
> Looks like rhashtable has too much policy in it to properly deal with
> cases where there are too many hash collisions, so I am going to work
> on reverting it's use in mac80211.

I'm not really all that happy with that approach - can't we fix the
rhashtable? It's a pretty rare corner case that many keys really are
identical and no kind of hash algorithm, but it seems much better to
still deal with it than to remove the rhashtable usage and go back to
hand-rolling something.

johannes
