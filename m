From: Ralph Sennhauser <ralph.sennhauser@gmail.com>
Subject: Re: [REGRESSION next-20170426] Commit 09515ef5ddad ("of/acpi:
 Configure dma operations at probe time for platform/amba/pci bus devices")
 causes oops in mvneta
Date: Thu, 27 Apr 2017 16:40:14 +0200
Message-ID: <20170427164014.422a124c@gmail.com>
References: <20170426181508.687b52af@gmail.com>
 <2fb57b9b-3944-d9cc-1fac-8dcccaa0c37a@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Joerg Roedel <jroedel@suse.de>,
        Bjorn Helgaas <bhelgaas@google.com>,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-pci@vger.kernel.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org
To: Sricharan R <sricharan@codeaurora.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <2fb57b9b-3944-d9cc-1fac-8dcccaa0c37a@codeaurora.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Apr 2017 19:05:09 +0530
Sricharan R <sricharan@codeaurora.org> wrote:

> Hi,
> 
> On 4/26/2017 9:45 PM, Ralph Sennhauser wrote:
> > Hi Sricharan R,
> > 
> > Commit 09515ef5ddad ("of/acpi: Configure dma operations at probe
> > time for platform/amba/pci bus devices") causes a kernel panic as
> > in the log below on an armada-385. Reverting the commit fixes the
> > issue.
> > 
> > Regards
> > Ralph  
> 
> Somehow not getting a obvious clue on whats going wrong with the logs
> below. From the log and looking in to dts, the drivers seems to the
> one for "marvell,armada-370-neta".

Correct.

> Issue looks the data from the dma
> has gone bad and subsequently referring the wrong data has resulted
> in the crash. Looks like the dma_masks is the one going wrong.
> Can i get some logs from mvneta_probe, about dev->dma_mask,
> dev->coherent_dma_mask and dev->dma_ops with and without the patch
> to see whats the difference ?

Not sure I understood what exactly you are after. Might be faster to
just send me a patch with all debug print statements you like to see.

Regards
Ralph
