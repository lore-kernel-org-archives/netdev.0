From: Robert Richter <robert.richter@caviumnetworks.com>
Subject: Re: [PATCH] VNIC: Adding support for Cavium ThunderX network
 controller
Date: Fri, 31 Oct 2014 17:17:24 +0100
Message-ID: <20141031161724.GC31556@rric.localhost>
References: <20141030165434.GW20170@rric.localhost>
 <20141030194513.089d27ec@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <rric@kernel.org>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Stefan Assmann <sassmann@redhat.com>,
 Sunil Goutham <sgoutham@cavium.com>, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20141030194513.089d27ec@urahara>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 30.10.14 19:45:13, Stephen Hemminger wrote:
> On Thu, 30 Oct 2014 17:54:34 +0100
> Robert Richter <rric@kernel.org> wrote:
> 
> > diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
> > index 1fa99a301817..80bd3336691e 100644
> > --- a/include/linux/pci_ids.h
> > +++ b/include/linux/pci_ids.h
> > @@ -2324,6 +2324,8 @@
> >  #define PCI_DEVICE_ID_ALTIMA_AC9100	0x03ea
> >  #define PCI_DEVICE_ID_ALTIMA_AC1003	0x03eb
> >  
> > +#define PCI_VENDOR_ID_CAVIUM		0x177d
> 
> I don't think PCI folks want this updated with every id anymore.

This is just the vendor id, the device id is part of the driver.

Since there will be multiple drivers I put the vendor id here.

-Robert
