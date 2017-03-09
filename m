From: "Reshetova, Elena" <elena.reshetova@intel.com>
Subject: RE: [PATCH 22/29] drivers, scsi: convert iscsi_task.refcount from
 atomic_t to refcount_t
Date: Thu, 9 Mar 2017 09:26:03 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B41C56ABF@IRSMSX102.ger.corp.intel.com>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
 <1488810076-3754-23-git-send-email-elena.reshetova@intel.com>
 <20170308184740.4gueok5csdkt7u62@straylight.hirudinean.org>
 <2236FBA76BA1254E88B949DDB74E612B41C569DC@IRSMSX102.ger.corp.intel.com>
 <5a1f7860-b650-9fe7-fafb-1f0c7cae00e7@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
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
 "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
 "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
 "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
 Kees Cook <keescook@chromium.org>,
 "linux-raid@vger.kernel.org" <linux-raid@vger.kernel.org>,
 "linux-bcache@vger.kernel.org" <linux-bcache@vger.kerne
To: Johannes Thumshirn <jthumshirn@suse.de>, Chris Leech <cleech@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <5a1f7860-b650-9fe7-fafb-1f0c7cae00e7@suse.de>
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


> On 03/09/2017 08:18 AM, Reshetova, Elena wrote:
> >> On Mon, Mar 06, 2017 at 04:21:09PM +0200, Elena Reshetova wrote:
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
> >>
> >> This looks OK to me.
> >>
> >> Acked-by: Chris Leech <cleech@redhat.com>
> >
> > Thank you for review! Do you have a tree that can take this change?
> =

> Hi Elena,
> =

> iscsi like fcoe should go via the SCSI tree.

Thanks Johannes! Should I resend with "Acked-by" added in order for it to b=
e picked up? =


Best Regards,
Elena.


> =

> Byte,
> 	Johannes
> =

> --
> Johannes Thumshirn                                          Storage
> jthumshirn@suse.de                                +49 911 74053 689
> SUSE LINUX GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
> GF: Felix Imend=F6rffer, Jane Smithard, Graham Norton
> HRB 21284 (AG N=FCrnberg)
> Key fingerprint =3D EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
