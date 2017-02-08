From: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v3 01/11] IB/hfi-vnic: Virtual Network Interface
 Controller (VNIC) documentation
Date: Wed, 8 Feb 2017 17:00:45 +0000
Message-ID: <1486573231.16026.1.camel@sandisk.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
         <1486498990-76562-2-git-send-email-niranjana.vishwanathapura@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org"
        <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1486498990-76562-2-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Content-ID: <1F8A08B704AB7946A2383CD069275614-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-02-07 at 12:23 -0800, Vishwanathapura, Niranjana wrote:
> diff --git a/Documentation/infiniband/hfi_vnic.txt b/Documentation/infiniband/hfi_vnic.txt
> new file mode 100644
> index 0000000..c6c801e
> --- /dev/null
> +++ b/Documentation/infiniband/hfi_vnic.txt
> @@ -0,0 +1,102 @@
> +Intel Omni-Path Host Fabric Interface (HFI) Virtual Network Interface
> +Controller (VNIC) feature supports Ethernet functionality over Omni-Path
> +fabric by encapsulating the Ethernet packets between HFI nodes.

Please add a reference to the document that defines the Ethernet encapsulation
wire protocol.

> +The patterns of exchanges of Omni-Path encapsulated Ethernet packets
> +involves one or more virtual Ethernet switches overlaid on the Omni-Path
> +fabric topology. A subset of HFI nodes on the Omni-Path fabric are
> +permitted to exchange encapsulated Ethernet packets across a particular
> +virtual Ethernet switch. The virtual Ethernet switches are logical
> +abstractions achieved by configuring the HFI nodes on the fabric for
> +header generation and processing. In the simplest configuration all HFI
> +nodes across the fabric exchange encapsulated Ethernet packets over a
> +single virtual Ethernet switch. A virtual Ethernet switch, is effectively
> +an independent Ethernet network. The configuration is performed by an
> +Ethernet Manager (EM) which is part of the trusted Fabric Manager (FM)
> +application. HFI nodes can have multiple VNICs each connected to a
> +different virtual Ethernet switch. The below diagram presents a case
> +of two virtual Ethernet switches with two HFI nodes.

Please elaborate this section. What is a virtual Ethernet switch? Is it a
software entity or something that is implemented in hardware? Also, how are
these independent Ethernet networks identified on the wire? The Linux kernel
already supports IB partitions and Ethernet VLANs. How do these independent
Ethernet networks compare to IB partitions and Ethernet VLANs? Which wire-
level header contains the identity of these Ethernet networks? Is it
possible to query from user space which Ethernet network a VNIC belongs to?
If so, with which API and which tools?

Thanks,

Bart.--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
