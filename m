From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Pv-drivers] [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Sat, 26 Jan 2013 13:41:58 -0500
Message-ID: <20130126184158.GA1388@neilslaptop.think-freely.org>
References: <1359135470-30677-1-git-send-email-acking@vmware.com>
	<1359135470-30677-2-git-send-email-acking@vmware.com>
	<20130125235953.GA4833@hmsreliant.think-freely.org>
	<2312112.Fz0qTjDOJB@dtor-d630.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: acking@vmware.com, pv-drivers@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Dmitry Torokhov <dtor@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <2312112.Fz0qTjDOJB@dtor-d630.eng.vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 25, 2013 at 04:15:19PM -0800, Dmitry Torokhov wrote:
> Hi Neil,
> 
> On Friday, January 25, 2013 06:59:53 PM Neil Horman wrote:
> > On Fri, Jan 25, 2013 at 09:37:50AM -0800, acking@vmware.com wrote:
> > > +
> > > +config VMWARE_VSOCK
> > > +	tristate "Virtual Socket protocol"
> > > +	depends on VMWARE_VMCI
> > 
> > What is CONFIG_VMWARE_VMCI?  I don't find that in any Kconfig in the tree?
> > 
> > I''m still looking over the rest, but I get build issues if I just remove
> > the dependency.
> 
> VMCI is in linux-next at the moment.
> 
> Thanks,
> Dmitry
> 


Thanks, I'll pull that in.
Neil
