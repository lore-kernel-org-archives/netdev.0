From: Gerd Hoffmann <kraxel@redhat.com>
Subject: Re: [Pv-drivers] [PATCH 0/6] VSOCK for Linux upstreaming
Date: Wed, 09 Jan 2013 09:10:15 +0100
Message-ID: <50ED25E7.9010609@redhat.com>
References: <20130109002110.GB5296@kroah.com>
	<20130108.173056.1029788106028104571.davem@davemloft.net>
	<1683801.VNKd61ZM1Q@dtor-d630.eng.vmware.com>
	<20130108.174601.1788895671912734725.davem@davemloft.net>
	<20130109022204.GA22875@dtor-ws.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Dmitry Torokhov <dtor@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130109022204.GA22875@dtor-ws.eng.vmware.com>
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

On 01/09/13 03:22, Dmitry Torokhov wrote:
> On Tue, Jan 08, 2013 at 05:46:01PM -0800, David Miller wrote:
>> I'd much rather see a hypervisor neutral solution than a hypervisor
>> specific one which this certainly is.
> 
> Objectively speaking neither solution is hypervisor neutral as there are
> hypervisors that implement either VMCI or virtio or something else
> entirely.

Indeed.  vmchannel is tied to virtio like vsock is tied to vmci.

> Our position is that VSOCK feature set is more complete and that it
> should be possible to use transports other than VMCI for VSOCK traffic,
> should interested parties implement them,

Implementing other transports requires restructing vsock (and vmci)
first as the current vsock code is not a hypervisor neutral service.

cheers,
  Gerd
