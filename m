From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [PATCH] convering bonding driver /proc interface to seq_file
Date: Tue, 26 Aug 2003 10:45:16 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308261045.16910.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A0251EB62@hasmsx403.iil.intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: "James Morris" <jmorris@intercode.com.au>,
   <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A0251EB62@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 25 August 2003 10:27 pm, Stephen Hemminger wrote:
>
> #ifndef PDE
> #define PDE(i) ((struct proc_dir_entry *)(i)->u.generic_ip)
> #endif

When you're right, you're right. We didn't know we could do that 
safely in 2.4.

How about the following suggestion:
I'll take it as my personal commitment to implement the fix you've 
suggested, along with that of James, but only after the 2.4<->2.6 
synchronization is complete.

After all, my word is my bond(ing) :)

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
