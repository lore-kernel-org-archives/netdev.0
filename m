From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] wimax: fix '#ifndef CONFIG_BUG' layout to avoid
 warning
Date: Thu, 08 Jan 2009 11:07:03 -0800 (PST)
Message-ID: <20090108.110703.224751826.davem@davemloft.net>
References: <cover.1231355768.git.inaky@linux.intel.com>
	<7e92a3e498e02567876f901eba29c59c294a417b.1231355768.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au, wimax@linuxwimax.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wimax@intel.com, linux-next@vger.kernel.org, greg@kroah.com
To: inaky@linux.intel.com
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <7e92a3e498e02567876f901eba29c59c294a417b.1231355768.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Wed,  7 Jan 2009 11:22:19 -0800

> Reported by Randy Dunlap:
> 
> > Also, this warning needs to be fixed:
> >
> > linux-next-20090106/net/wimax/id-table.c:133: warning: ISO C90
> > forbids mixed declarations and code
> 
> Move the return on #defined(CONFIG_BUG) below the variable
> declarations so it doesn't violate ISO C90.
> 
> On wimax_id_table_release() we want to do a debug check if CONFIG_BUG
> is enabled. However, we also want the debug code to be always compiled
> to ensure there is no bitrot. It will be optimized out by the compiler
> when CONFIG_BUG is disabled.
> 
> Added a note to the function header stating this.
> 
> Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>

Applied.
