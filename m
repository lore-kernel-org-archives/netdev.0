From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: git repository for net drivers available
Date: Fri, 13 May 2005 10:18:38 -0500
Message-ID: <4284C54E.3060907@linux.intel.com>
References: <42841A3F.7020909@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262398AbVEMPSL@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <42841A3F.7020909@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

>
> This includes the wireless-2.6 repository.
>
> rsync://rsync.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
>
> The main branch is fairly irrelevant, as you must choose the branch
> you wish:
>
>> [jgarzik@pretzel netdev-2.6]$ ls .git/branches/
>> 8139cp         e1000        ixgb     r8169            skge          
>> we18
>> 8139too-iomap  forcedeth    janitor  register-netdev  smc91x        
>> wifi
>> amd8111        ieee80211    orinoco  remove-drivers   smc91x-eeprom
>> e100           iff-running  ppp      sis900           starfire
>
Ok, I'll bite.  Hopefully I'm not the only one tripping on shoe laces...

Here is what I did -- what am I doing wrong?

Following is using cogito 0.10:

REPO=rsync://rsync.kernel.org/pubs/scm/linux/kernel/git/jgarzik/netdev-2.6.git
cg-clone ${REPO}
.... get coffee, etc. ... come back and I have a netdev-2.6 tree ...
cg-branch-add wifi ${REPO}#wifi
cg-update wifi
.... connects and attempts to download but fails out with:

----------------
receiving file list ... done
client: nothing to do: perhaps you need to specify some filenames or the
--recursive option?

rsync: link_stat
"/scm/linux/kernel/git/jgarzik/netdev-2.6.git/heads/wifi" (in pub)
failed: No such file or directory (2)
rsync error: some files could not be transferred (code 23) at main.c(653)
receiving file list ... done
client: nothing to do: perhaps you need to specify some filenames or the
--recursive option?
cg-pull: unable to get the head pointer of branch wifi
----------------

Should it be trying to get 'wifi' from ...netdev-2.6.git/branches (vs.
heads)? 

Tool problem, user problem, complete lack of knowledge re: git and
cogito, or a combination of the above?

Thanks,
James
