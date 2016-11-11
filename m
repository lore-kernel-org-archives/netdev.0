From: Paul Menzel <pmenzel@molgen.mpg.de>
Subject: Re: [PATCH 1/2] Revert "bnx2: Reset device during driver
 initialization"
Date: Fri, 11 Nov 2016 14:51:47 +0100
Message-ID: <ed7bc8d7-91be-a2a5-940c-6b8b6b8a7c44@molgen.mpg.de>
References: <1478871995-29652-1-git-send-email-bhe@redhat.com>
 <1478871995-29652-2-git-send-email-bhe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Dept-GELinuxNICDev@cavium.com,
        rasesh.mody@cavium.com, harish.patil@cavium.com,
        frank@undermydesk.org, jsr@dex.edzone.net, jroedel@suse.de,
        dyoung@redhat.com
To: Baoquan He <bhe@redhat.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478871995-29652-2-git-send-email-bhe@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Baoquan,


On 11/11/16 14:46, Baoquan He wrote:
> This reverts commit 3e1be7ad2d38c6bd6aeef96df9bd0a7822f4e51c.

Thanks a lot.

> When people build bnx2 driver into kernel, it will fail to detect
> and load firmware because firmware is contained in initramfs and
> initramfs has not been uncompressed yet during do_initcalls. So
> revert commit 3e1be7a and work out a new way in the later patch.

Just to note, that the other reason is, that in some installations 
people don’t have the firmware in initramfs at all or don’t use an 
initramfs.

> Signed-off-by: Baoquan He <bhe@redhat.com>

Please mark this for inclusion into the stable Linux kernel.

Acked-by: Paul Menzel <pmenzel@molgen.mpg.de>


Thanks,

Paul
