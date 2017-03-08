From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 08/29] drivers, md: convert mddev.active from atomic_t to
 refcount_t
Date: Wed, 8 Mar 2017 11:19:14 +0100
Message-ID: <20170308101914.GB15198@kroah.com>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
 <1488810076-3754-9-git-send-email-elena.reshetova@intel.com>
 <20170307190449.baceyzzngsz776x7@kernel.org>
 <2236FBA76BA1254E88B949DDB74E612B41C5606B@IRSMSX102.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "peterz@infradead.org" <peterz@infradead.org>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
 "linux1394-devel@lists.sourceforge.net"
 <linux1394-devel@lists.sourceforge.net>,
 "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
 "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
 "linux-serial@vger.kernel.org" <linux-serial@vger.kernel.org>,
 "fcoe-devel@open-fcoe.org" <fcoe-devel@open-fcoe.org>,
 Hans Liljestrand <ishkamiel@gmail.com>,
 "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
 Shaohua Li <shli@kernel.org>,
 "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
 Kees Cook <keescook@chromium.org>,
 "linux-raid@vger.kernel.org" <linux-raid@vger.kernel.org>,
 "linux-bcache@vger.kernel.org" <linux-bcache@vger.k
To: "Reshetova, Elena" <elena.reshetova@intel.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <2236FBA76BA1254E88B949DDB74E612B41C5606B@IRSMSX102.ger.corp.intel.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Wed, Mar 08, 2017 at 09:42:09AM +0000, Reshetova, Elena wrote:
> > On Mon, Mar 06, 2017 at 04:20:55PM +0200, Elena Reshetova wrote:
> > > refcount_t type and corresponding API should be
> > > used instead of atomic_t when the variable is used as
> > > a reference counter. This allows to avoid accidental
> > > refcounter overflows that might lead to use-after-free
> > > situations.
> > 
> > Looks good. Let me know how do you want to route the patch to upstream.
> 
> Greg, you previously mentioned that driver's conversions can go via your tree. Does this still apply?
> Or should I be asking maintainers to merge these patches via their trees? 

You should ask them to take them through their trees, if they have them.
I'll be glad to scoop up all of the remaining ones that get missed, or
for subsystems that do not have trees.

thanks,

greg k-h
