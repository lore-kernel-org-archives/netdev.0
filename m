From: Juergen Gross <jgross@suse.com>
Subject: Re: [PATCH 00/12] xen: add common function for reading optional value
Date: Tue, 1 Nov 2016 05:33:01 +0100
Message-ID: <76a0c445-c345-fdf4-12b1-974491f6a77e@suse.com>
References: <1477932510-28594-1-git-send-email-jgross@suse.com>
 <20161031.130831.2006896157400677867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xen.org,
        david.vrabel@citrix.com, boris.ostrovsky@oracle.com,
        konrad.wilk@oracle.com, roger.pau@citrix.com, peterhuewe@gmx.de,
        tpmdd@selhorst.net, jarkko.sakkinen@linux.intel.com,
        jgunthorpe@obsidianresearch.com, tpmdd-devel@lists.sourceforge.net,
        dmitry.torokhov@gmail.com, linux-input@vger.kernel.org,
        wei.liu2@citrix.com, paul.durrant@citrix.com,
        netdev@vger.kernel.org, bhelgaas@google.com,
        linux-pci@vger.kernel.org, tomi.valkeinen@ti.com,
        linux-fbdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20161031.130831.2006896157400677867.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31/10/16 18:08, David Miller wrote:
> From: Juergen Gross <jgross@suse.com>
> Date: Mon, 31 Oct 2016 17:48:18 +0100
> 
>> There are multiple instances of code reading an optional unsigned
>> parameter from Xenstore via xenbus_scanf(). Instead of repeating the
>> same code over and over add a service function doing the job and
>> replace the call of xenbus_scanf() with the call of the new function
>> where appropriate.
> 
> As this seems to be a series that will go through some tree other
> than mine, I assume the networking bits will be taken care of that
> way.
> 

If accepted I expect this series to go through the Xen tree.


Juergen
