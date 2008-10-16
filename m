From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: powerpc allmodconfig
Date: Thu, 16 Oct 2008 09:22:15 -0700
Message-ID: <4807377b0810160922q70fdcc95u36d937f29c473f14@mail.gmail.com>
References: <20081015.220247.262683261.davem@davemloft.net>
	 <1224137292.26782.5.camel@dwillia2-linux.ch.intel.com>
	 <48F6E54C.5010207@myri.com>
	 <20081015.235844.206136521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: brice@myri.com, dan.j.williams@intel.com,
	akpm@linux-foundation.org, tiwai@suse.de,
	linux-ext4@vger.kernel.org, netdev@vger.kernel.org,
	linux-ide@vger.kernel.org, bzolnier@gmail.com,
	marek.vasut@gmail.com, dwmw2@infradead.org, mark.fasheh@oracle.com,
	ralf@linux-mips.org, mchehab@infradead.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jesse.brandeburg@intel.com
To: "David Miller" <davem@davemloft.net>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <20081015.235844.206136521.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 15, 2008 at 11:58 PM, David Miller <davem@davemloft.net> wrote:
>> There's already a completely different fix queued in netdev patchworks
>> (for myri10ge only right now, to be duplicated for Intel drivers). The
>> idea is to stop having almost-unrelated drivers select each other
>> directly, let people select which drivers they really want, and have
>> Kconfig handle modules/builtin-stuff correctly. See
>> http://patchwork.ozlabs.org/patch/4506/
>
> Right, my plan was to duplicate this for the other drivers.

The work is already done for ixgbe and igb, and we have it in testing.
 It should be in your inbox today or tomorrow.
