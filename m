From: "Reshetova, Elena" <elena.reshetova@intel.com>
Subject: RE: [Xen-devel] [PATCH 29/29] drivers, xen: convert grant_map.users
 from atomic_t to refcount_t
Date: Thu, 9 Mar 2017 07:19:12 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B41C569F1@IRSMSX102.ger.corp.intel.com>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
 <1488810076-3754-30-git-send-email-elena.reshetova@intel.com>
 <99270126-7751-eed0-5efa-fc695ff3be25@oracle.com>
 <2236FBA76BA1254E88B949DDB74E612B41C56177@IRSMSX102.ger.corp.intel.com>
 <c4ea3925-f505-3c5b-a9fc-c74ea5a7cbe9@oracle.com>
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
 "fcoe-devel@open-fcoe.org" <fcoe-devel@open-fcoe.org>, Hans
 Liljestrand <ishkamiel@gmail.com>,
 "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
 "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
 Kees Cook <keescook@chromium.org>,
 "linux-raid@vger.kernel.org" <linux-raid@vger.kernel.org>,
 "linux-bcache@vger.kernel.org" <linux-bcache@vger.kernel.org>,
 "xen-devel@lists.x
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>, "gregkh@linuxfoundation.org"
 <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <c4ea3925-f505-3c5b-a9fc-c74ea5a7cbe9@oracle.com>
Content-Language: en-US
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


> On 03/08/2017 08:49 AM, Reshetova, Elena wrote:
> >> On 03/06/2017 09:21 AM, Elena Reshetova wrote:
> >>> refcount_t type and corresponding API should be
> >>> used instead of atomic_t when the variable is used as
> >>> a reference counter. This allows to avoid accidental
> >>> refcounter overflows that might lead to use-after-free
> >>> situations.
> >>>
> >>> Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> >>> Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
> >>> Signed-off-by: Kees Cook <keescook@chromium.org>
> >>> Signed-off-by: David Windsor <dwindsor@gmail.com>
> >>> ---
> >>>  drivers/xen/gntdev.c | 11 ++++++-----
> >>>  1 file changed, 6 insertions(+), 5 deletions(-)
> >> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> > Is there a tree that can take this change? Turns out it is better to propagate
> changes via separate trees and only leftovers can be taken via Greg's tree.
> >
> 
> Sure, we can take it via Xen tree for rc3.

Thank you very much!

Best Regards,
Elena.

> 
> -boris
