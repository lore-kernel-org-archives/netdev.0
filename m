From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH] ibmtr: fix init (devinit) section usage
Date: Wed, 4 Aug 2004 14:12:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804141221.5a230b77.rddunlap@osdl.org>
References: <20040804094905.667b3954.rddunlap@osdl.org>
	<OF5BF82238.ABA1EE0F-ON85256EE6.0064AACC-85256EE6.0064C0D5@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mike_Phillips@URSCorp.com
In-Reply-To: <OF5BF82238.ABA1EE0F-ON85256EE6.0064AACC-85256EE6.0064C0D5@urscorp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 4 Aug 2004 14:20:31 -0400 Mike_Phillips@URSCorp.com wrote:

| Randy:
| 
| Does ibmtr_cs still compile with those changes ? It links in ibmtr.c and 
| the probe functions. 

Yes, it builds fine.  If HOTPLUG=y, __devinit means <emtpy>.
If HOTPLUG=n, it means __init.

Also note that ibmtr_probe1() is already marked as __devinit.

--
~Randy
