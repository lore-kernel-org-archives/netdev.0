From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [PATCH] convering bonding driver /proc interface to seq_file
Date: Sun, 24 Aug 2003 20:12:58 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308242012.58116.shmulik.hen@intel.com>
References: <Mutt.LNX.4.44.0308250112470.21951-100000@excalibur.intercode.com.au>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Mutt.LNX.4.44.0308250112470.21951-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 24 August 2003 06:15 pm, James Morris wrote:
>
> Can you provide a pointer to this code?
>

Please see my email from August 8th with subject:
"[SET 1][PATCH 3/6][bonding] backport 2.6 changes to 2.4"
sent to netdev@oss.sgi.com and bonding-devel@lists.sourceforge.net.

> seq_file is the standard and preferred way to do this kind of
> thing.

Yes, we know. We wanted to convert to seq_file too, but as it turns 
out, in order to create a separate proc file for each bond device you 
need to use the PDE(inode) macro which doesn't exist in 2.4 yet. 
Since we wanted to maintain compatibility in the bonding module 
between 2.4 and 2.6 as much as possible, we figured that as a first 
step we'll start using bond_read_proc() instead of bond_get_info() to 
allow just that.

BTW, we really like the change from /proc/net/bond0/info to 
/proc/net/bonding/bond0. We thought we'll add that into our cleanup 
patch set that should come out once the back porting set is accepted.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
