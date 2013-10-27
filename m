From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/3] vxlan: silence one build warning
Date: Sun, 27 Oct 2013 12:33:52 -0700
Message-ID: <20131027123352.3d49d75b@nehalam.linuxnetplumber.net>
References: <1382687360-27794-1-git-send-email-zwu.kernel@gmail.com>
	<20131025084134.6cfa153a@samsung-9>
	<CAEH94Lia4VVU6Vnn_7DhOHo4yhR-tsMPu7biMCeSMgQPvkQrug@mail.gmail.com>
	<20131026074819.6a5f4e24@samsung-9>
	<CAEH94LjOnWgchhV__TLK9se-Cb3WkGnVfNZgNBBLdZL0kNM=-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel mlist <linux-kernel@vger.kernel.org>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEH94LjOnWgchhV__TLK9se-Cb3WkGnVfNZgNBBLdZL0kNM=-g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 27 Oct 2013 10:30:56 +0800
Zhi Yong Wu <zwu.kernel@gmail.com> wrote:

> HI, Stephen
> 
> I saw it on Fedora 17 without latest kernel. Then what do you think
> that it is appropriate to solve this problem? discard this patch? If
> yes, i can also agree.
> 

Either find where the uninitialized use is being caused by finding the code
path where it happens (manual analysis), or ignore the warning.
