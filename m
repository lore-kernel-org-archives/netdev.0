From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: Re: [PATCH] Drivers: isdn: gigaset: checkpatch cleanup
Date: Wed, 31 Dec 2014 09:49:36 -0800
Message-ID: <20141231174936.GB1922@hudson.localdomain>
References: <1420047298-7798-1-git-send-email-baspeters93@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hjlipp@web.de, tilman@imap.cc, isdn@linux-pingi.de,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bas Peters <baspeters93@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1420047298-7798-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bas,

On Wed, Dec 31, 2014 at 06:34:58PM +0100, Bas Peters wrote:
> Fixed many checkpatch.pl complaints, ranging from whitespace issues to
> reportedly deprecated function and macro usage.
> 
One patch should fix one type of problem.  This needs to be broken up
in to individual patches.

> I have not been able to test the code as I do not have access to the
> hardware but since no new features were really added I don't think that
> should pose a problem.
> 
> There are still some checkpatch complaints, particularly concerning
> potentially unnecessary 'out of memory' messages. I will provide patches
> for these complaints when I figure out the reason behind it and what to
> do about it.
> 
> NOTE: This is my first patch (ever). I have attempted to follow all
> guidelines provided, but I probably will have missed some. If you have
> any comments regarding the quality of this patch or suggestions as to
> what I could do better in the future, please let me know.
> 
You are ambitious.  I would suggest trying a smaller patch first to
make sure you are doing everything right.

> Signed-off-by: Bas Peters <baspeters93@gmail.com>
> ---
>  drivers/isdn/gigaset/asyncdata.c   |  9 +++--
>  drivers/isdn/gigaset/bas-gigaset.c | 80 ++++++++++++++++++++------------------
>  drivers/isdn/gigaset/capi.c        |  5 ++-
>  drivers/isdn/gigaset/common.c      |  8 ++--
>  drivers/isdn/gigaset/ev-layer.c    | 38 +++++++++++-------
>  drivers/isdn/gigaset/gigaset.h     |  4 +-
>  drivers/isdn/gigaset/i4l.c         | 12 +++---
>  drivers/isdn/gigaset/interface.c   | 10 ++---
>  drivers/isdn/gigaset/isocdata.c    |  3 ++
>  drivers/isdn/gigaset/proc.c        | 17 +++++---
>  drivers/isdn/gigaset/usb-gigaset.c | 46 +++++++++++++++-------
>  11 files changed, 141 insertions(+), 91 deletions(-)
> 
> diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
[...]

-- 
- Jeremiah Mahler
