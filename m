From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: patches for PROC_FS=n (2.6.0-test7)
Date: Sat, 11 Oct 2003 20:24:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031011202433.72fcbd38.rddunlap@osdl.org>
References: <20031010141646.779f10bb.rddunlap@osdl.org>
	<20031011120852.13fa8ec4.davem@redhat.com>
	<20031011194008.GA2395@mars.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sam Ravnborg <sam@ravnborg.org>
In-Reply-To: <20031011194008.GA2395@mars.ravnborg.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 11 Oct 2003 21:40:08 +0200 Sam Ravnborg <sam@ravnborg.org> wrote:

| On Sat, Oct 11, 2003 at 12:08:52PM -0700, David S. Miller wrote:
| > On Fri, 10 Oct 2003 14:16:46 -0700
| > "Randy.Dunlap" <rddunlap@osdl.org> wrote:
| > 
| > > http://developer.osdl.org/rddunlap/patches/atmprocfs_260t7.patch
| > 
| > How can this be needed?  When procfs is disabled then
| > remove_proc_entry() is defined as "do { } while (0)", ie. a nop.
| 
| Due to this - the real offender:
| 
| from: net/atm/clip.c:
| #ifdef CONFIG_PROC_FS
| #include <linux/proc_fs.h>
| #include <linux/seq_file.h>
| #endif

ugh, thanks.

--
~Randy
