From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [BUILD_FAILURE] linux-next: 20081125 - 8390 network driver build
 fails
Date: Tue, 25 Nov 2008 11:34:12 -0800
Message-ID: <492C5334.2090801@oracle.com>
References: <20081125213738.881b425e.sfr@canb.auug.org.au>	<20081125182542.GA4914@linux.vnet.ibm.com>	<492C464D.4080704@oracle.com> <20081125185154.2845e8f1@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	p_gortmaker@yahoo.com, netdev@vger.kernel.org, mel@csn.ul.ie
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20081125185154.2845e8f1@lxorguk.ukuu.org.uk>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
>> I just reported this on netdev and said that DaveM might want to drop a patch
>> that I had submitted.  Anyway, I'm looking into it.
> 
> Ditto and the only sane interpretation I can see is that someone
> somewhere has crap in their tree that does
> 
> #define static
> 
> and this is leaking out.

The problem is that both 8390.c and 8390p.c #include lib8390.c
and when they are both linked to built-in drivers (not loadable
modules), the symbols in lib8390.c are duplicated.  I think.

~Randy
