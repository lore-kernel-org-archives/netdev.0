From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH wireless-2.6 0/12] Host AP update
Date: Sat, 13 Nov 2004 21:15:33 -0800
Message-ID: <20041114051533.GA14810@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu> <41907A06.2040702@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>,
        James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41907A06.2040702@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 09, 2004 at 03:04:22AM -0500, Jeff Garzik wrote:

> Andrew Morton's "-mm" kernels are essentially a staging area for pushing 
> changes to the upstream kernel.  I pulled the latest wireless-2.6 tree 
> (includes your latest patches #1 - #9) into my netdev-2.6 queue. 
> netdev-2.6, in turn, is automatically pulled by Andrew, into his -mm 
> tree.  It will get wider review and testing here.

Thanks! I'll send couple of more patches to update the driver to Linux
2.6.10-rc1.

> A key goal I have for HostAP is that portions of HostAP code should be 
> bundled into a generic "lib80211" kernel module, for use by various 
> low-level and "softmac" 802.11 device drivers.

Agreed.

> The Intel Centrino driver folks are already using HostAP in this 
> capacity, and I _think_ their changes were fairly minimal and cosmetic. 
>    If the changes are indeed minimal, I think it's better to merge 
> those changes before sending HostAP stuff upstream.

I haven't went through all the changes in Intel driver, but at least
IEEE 802.11g support is going to require quite a bit more work and IEEE
802.11a and Atheros-like hardware even more.

> To emphasize that the upstream-bound HostAP code is a generic library 
> (well, parts of it), I would prefer that the kernel module name, and API 
> prefixes, use some name other than 'hostap_'.  'wifi_' or 'ieee80211_' 
> or whatever, I don't care.  Just something "more generic".
> 
> I would rather perform mass renaming of functions and files before 
> merging upstream.

I can start cleaning up some of the functions and renaming them in the
code. However, I still want to finalize couple of things in my
employment agreement before starting doing more "non-Host AP" things.
I would thus prefer to be able to get current Host AP driver merged
upstream before doing full merge with other drivers (I would add at
least net80211/madwifi to the list with Intel drivers). This would allow
me to maintain stable version of Host AP driver without having to do too
much work with an external CVS repository and start working on
wireless-2.6 for the generic library and merging.

> IMHO the bksend stuff is useless.  I prefer "plain ole patches", like 
> the ones you sent in emails '1/12' through '12/12' in this thread.

OK.

> WRT the patches you sent, as I mentioned, #1 - #9 were applied.  Please 
> update #10 and #11 per comments, and then resend #10 - #12.

I have updated #10 and #11 and added couple of more patches (13..16) to
match with the Linux 2.6.10-rc1 pull into wireless-2.6. I'll re-send
10..12 and send 13..16.

-- 
Jouni Malinen                                            PGP id EFC895FA
