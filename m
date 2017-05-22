From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: vhost/scsi: Delete error messages for failed memory allocations
 in five functions
Date: Mon, 22 May 2017 13:34:34 +0200
Message-ID: <e6658e56-a2b0-4ecc-0a95-0ba193ff2c97@users.sourceforge.net>
References: <bafa65e4-08fe-efdb-d836-7657e8a64749@users.sourceforge.net>
 <babc429d-6440-92aa-e1d0-eee2636a8d0f@users.sourceforge.net>
 <20170522094320.GE12205@stefanha-x1.localdomain>
 <557bdff4-6dc2-756d-0d59-9f688ef11f0a@users.sourceforge.net>
 <20170522112320.GA22806@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        kernel-janitors@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Wolfram Sang <wsa@the-dreams.de>
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20170522112320.GA22806@stefanha-x1.localdomain>
Content-Language: en-GB
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Do you find information from a Linux allocation failure report sufficient
>> for any function implementations here?
> 
> If kmalloc() and friends guarantee to print a warning and backtrace on
> every allocation failure, then there's no need for error messages in
> callers.
> 
> That seems like good justification that can go in the commit
> description, but I'm not sure if kmalloc() and friends guarantee to show
> a message (not just the first time, but for every failed allocation)?

I am also looking for a more complete and easier accessible documentation
for this aspect of the desired exception handling.
How would we like to resolve any remaining open issues there?

Regards,
Markus
