From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: kmalloc panic
Date: Thu, 28 May 2015 11:03:13 +0200
Message-ID: <1432803793.2459.2.camel@sipsolutions.net>
References: <5565CAA1.9070409@redpinesignals.com>
	 <CAM_iQpUGLW44vzkN-5TJ9ww3RSz=2sRMnm7GKP6V0N9WGszRZQ@mail.gmail.com>
	 (sfid-20150528_071604_270429_6EC02675)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pavani <pavani.muthyala@redpinesignals.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-wireless@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUGLW44vzkN-5TJ9ww3RSz=2sRMnm7GKP6V0N9WGszRZQ@mail.gmail.com> (sfid-20150528_071604_270429_6EC02675)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-05-27 at 22:15 -0700, Cong Wang wrote:

> > rsi_client: module license 'Proprietary' taints kernel.
> > Disabling lock debugging due to kernel taint
> > RSI_Init called and registering the client driver

If this is what I think it is - the redpine signals wifi driver, then I
have no interest in this bug report whatsoever.

Please tell us
 * the exact kernel version, best with local patches
 * the wifi driver used

> > INFO: Allocated in 0x10100100 age=2669517238 cpu=16842820 pid=335563024

and what function this really was (0x10100100 isn't really useful).

johannes
