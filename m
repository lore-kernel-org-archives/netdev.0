From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: [net] e1000e: enable ECC on I217/I218 to catch packet buffer
 memory errors
Date: Mon, 28 Jan 2013 07:38:34 -0500
Message-ID: <CA+5PVA5i-jVrjtO1Lbm=DSWk0o+C6P87kqKUqNnbThafFF2o0A@mail.gmail.com>
References: <1359369828-13663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, Bruce Allan <bruce.w.allan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	stable@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1359369828-13663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 28, 2013 at 5:43 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
>
> In rare instances, memory errors have been detected in the internal packet
> buffer memory on I217/I218 when stressed under certain environmental
> conditions.  Enable Error Correcting Code (ECC) in hardware to catch both
> correctable and uncorrectable errors.  Correctable errors will be handled
> by the hardware.  Uncorrectable errors in the packet buffer will cause the
> packet to be received with an error indication in the buffer descriptor
> causing the packet to be discarded.  If the uncorrectable error is in the
> descriptor itself, the hardware will stop and interrupt the driver
> indicating the error.  The driver will then reset the hardware in order to
> clear the error and restart.
>
> Both types of errors will be accounted for in statistics counters.
>
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Cc: <stable@vger.kernel.org> # 3.5.x & 3.6.x

3.5.x is maintained by Canonical, not officially as a stable kernel (I
have no idea why).  3.6.x isn't maintained any longer.

Is this applicable to 3.4.x and 3.7.x?

josh
