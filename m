From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH wireless-2.6 0/12] Host AP update
Date: Tue, 09 Nov 2004 03:04:22 -0500
Message-ID: <41907A06.2040702@pobox.com>
References: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>,
        James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20041108070156.GA1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> Jeff,
> 
> Here's an update to Host AP code in wireless-2.6 tree. This brings in
> number of small fixes from my CVS repository. This messages has the
> changes in BitKeeper format from bksend and following 12 messages have
> the patches one by one as unified diffs.
> 
> I have couple of additional patches pending for wireless-2.6 updates
> (wireless extensions 17 and 18; changes to PCI API in Linux
> 2.6.10-rc1). I'll send WE17 and PCI changes once you update
> wireless-2.6. WE18 change requires an update to wireless extensions,
> so it may need to wait somewhat longer or we could start testing WE18
> in wireless-2.6 if that is desired.

Feel free to push experimental (but tested!) code to wireless-2.6.


> I keep getting questions about getting Host AP driver to linux-2.6
> tree. What would be needed to make this happen? I would assume this

Andrew Morton's "-mm" kernels are essentially a staging area for pushing 
changes to the upstream kernel.  I pulled the latest wireless-2.6 tree 
(includes your latest patches #1 - #9) into my netdev-2.6 queue. 
netdev-2.6, in turn, is automatically pulled by Andrew, into his -mm 
tree.  It will get wider review and testing here.


> would be easiest to do this from wireless-2.6 tree once the new
> patches are in. Any other changes that would be required to get the
> driver in suitable state for merging into Linux 2.6 releases?

A key goal I have for HostAP is that portions of HostAP code should be 
bundled into a generic "lib80211" kernel module, for use by various 
low-level and "softmac" 802.11 device drivers.

The Intel Centrino driver folks are already using HostAP in this 
capacity, and I _think_ their changes were fairly minimal and cosmetic. 
    If the changes are indeed minimal, I think it's better to merge 
those changes before sending HostAP stuff upstream.

To emphasize that the upstream-bound HostAP code is a generic library 
(well, parts of it), I would prefer that the kernel module name, and API 
prefixes, use some name other than 'hostap_'.  'wifi_' or 'ieee80211_' 
or whatever, I don't care.  Just something "more generic".

I would rather perform mass renaming of functions and files before 
merging upstream.


> You can import this changeset into BK by piping this whole message to:
> '| bk receive [path to repository]' or apply the patch as usual.

IMHO the bksend stuff is useless.  I prefer "plain ole patches", like 
the ones you sent in emails '1/12' through '12/12' in this thread.


WRT the patches you sent, as I mentioned, #1 - #9 were applied.  Please 
update #10 and #11 per comments, and then resend #10 - #12.

	Jeff
