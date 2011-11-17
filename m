From: David Decotigny <david.decotigny@google.com>
Subject: Re: [PATCH net-next v6 3/9] kbuild: document RPS/XPS network Kconfig options
Date: Wed, 16 Nov 2011 17:54:35 -0800
Message-ID: <CAG88wWZ853cHkykNbQ+Lqrk_D1p-SCmB0Y29YE6GpSSUORwCxg@mail.gmail.com>
References: <cover.1321481064.git.david.decotigny@google.com>
 <c7e7b57596f9a06b1c40c8b6e671cc6ac69dd304.1321481064.git.david.decotigny@google.com>
 <1321485122.2709.55.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	Tom Herbert <therbert@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321485122.2709.55.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 16, 2011 at 3:12 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2011-11-16 at 14:15 -0800, David Decotigny wrote:
>> This adds a description of RPS/XPS options and allow them to be
>> changed at make menuconfig time.
>
> I'm not sure why you think this is necessary.

On my copy, make menuconfig doesn't let me change these CONFIG_ items,
unless I add the string after "boolean", which this patch does. I
agree, the help I added after is pure cosmetic.

>> =A0config RFS_ACCEL
[...]
> RFS refers to directing RX packet processsing of specific flows based=
 on

Oops, you are right. I got confused and somehow read "RPS" instead of
"RFS" here. Thank you for the great explanation!

Will update this commit message. I don't know how patchwork handles
the follow-ups (it didn't work yesterday), so I'm afraid I will have
to send yet another batch of updates...

Regards,
