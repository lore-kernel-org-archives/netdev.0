From: Amir Noam <amir.noam@intel.com>
Subject: Re: major bonding bug?
Date: Tue, 30 Dec 2003 18:45:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312301845.14275.amir.noam@intel.com>
References: <E6F7D288B394A64585E67497E5126BA601F991CE@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Marom, Noam" <noam.marom@intel.com>, <netdev@oss.sgi.com>,
        <fubar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>, "Hen, Shmulik" <shmulik.hen@intel.com>
In-Reply-To: <E6F7D288B394A64585E67497E5126BA601F991CE@hasmsx403.iil.intel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 30 December 2003 06:31 pm, Jeff Garzik wrote:
> hmmm...
>
>
> It looks like a lot of code now depends on global variable
> "bond_mode".

Actually, this has always been the case in the bonding module.

> This looks very wrong...  bonding mode should be per-interface, not
> global to the entire driver.  What happens when a user wants
> BOND_MODE_ROUNDROBIN on bond0, and BOND_MODE_TLB on bond1?

We agree that it looks very wrong, and this is in fact one of the 
features we've been working on lately. It is not a trivial fix, 
since, as you've noted, a lot of the code depends on the bond 
settings being global. We plan to start releasing patches to address 
this issue very soon (probably even starting tomorrow).

-- 
Amir
