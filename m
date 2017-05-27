From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] hdlcdrv: Fix divide by zero in hdlcdrv_ioctl
Date: Sat, 27 May 2017 18:45:58 -0400 (EDT)
Message-ID: <20170527.184558.961743025477428078.davem@davemloft.net>
References: <CAAeHK+ya2sAtLmJ0VyP6e=13OXUw98dp1WdRFU=o5+xGFGPtbQ@mail.gmail.com>
        <20170526143738.26749-1-firogm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@linux.intel.com, t.sailer@alumni.ethz.ch, wharms@bfs.de,
        andreyknvl@google.com, linux-hams@vger.kernel.org,
        gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        thomas@osterried.de, javier@osg.samsung.com, dhowells@redhat.com,
        geliangtang@gmail.com, linux-kernel@vger.kernel.org
To: firogm@gmail.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20170526143738.26749-1-firogm@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Firo Yang <firogm@gmail.com>
Date: Fri, 26 May 2017 22:37:38 +0800

> syszkaller fuzzer triggered a divide by zero, when set calibration
> through ioctl().
> 
> To fix it, test 'bitrate' if it is negative or 0, just return -EINVAL.
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Firo Yang <firogm@gmail.com>

Applied, thank you.
