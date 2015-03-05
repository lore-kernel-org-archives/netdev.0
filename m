From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 0/7] Freescale DPAA FMan FLIB(s)
Date: Thu, 05 Mar 2015 07:32:49 -0500
Message-ID: <54F84CF1.80702@mojatatu.com>
References: <1425534351-1065-1-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Igal Liberman <Igal.Liberman@Freescale.com>
To: Emil Medve <Emilian.Medve@Freescale.com>,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425534351-1065-1-git-send-email-Emilian.Medve@Freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/05/15 00:45, Emil Medve wrote:
> From: Igal Liberman <Igal.Liberman@freescale.com>
>
> The Freescale Data Path Acceleration Architecture (DPAA) is a set of
> hardware components on specific QorIQ P and T series multicore processors.
> This architecture provides the infrastructure to support simplified
> sharing of networking interfaces and accelerators by multiple CPU cores,
> and the accelerators themselves.
>
> One of the DPAA accelerators is the Frame Manager (FMan), which
> combines the Ethernet network interfaces with packet distribution
> logic to provide intelligent distribution and queuing decisions for
> incoming traffic at line rate.
>
> This patch presents the FMan Foundation Libraries (FLIB) headers.
> The FMan FLIB suite adds basic support for the DPAA FMan hardware register access.
> The FMan FLIB suite is used in Freescale's SDK Releases.
>

Is this intended to merely enable your sdk? How are you planning to
add support for your classifiers, queue schedulers etc? Is that a patch
on top of this or it is something that sits on user space?

cheers,
jamal
