From: "David S. Miller" <davem@redhat.com>
Subject: Re: patches for PROC_FS=n (2.6.0-test7)
Date: Sat, 11 Oct 2003 12:08:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031011120852.13fa8ec4.davem@redhat.com>
References: <20031010141646.779f10bb.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20031010141646.779f10bb.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Oct 2003 14:16:46 -0700
"Randy.Dunlap" <rddunlap@osdl.org> wrote:

> http://developer.osdl.org/rddunlap/patches/atmprocfs_260t7.patch

How can this be needed?  When procfs is disabled then
remove_proc_entry() is defined as "do { } while (0)", ie. a nop.
