From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC PATCH net-next] enable virtio_net to return bus_info in
	ethtool -i consistent with emulated NICs
Date: Mon, 14 Nov 2011 16:14:34 -0800
Message-ID: <4EC1AEEA.903@hp.com>
References: <20111114215241.5B8BF2900307@tardy>
	<1321309800.2827.22.camel@bwh-desktop> <4EC1ACF6.9060908@hp.com>
	<1321315839.2827.25.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Michael Tsirkin <mst@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1321315839.2827.25.camel@bwh-desktop>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

>>> Please use the existing 'not implemented' value, which is the empty
>>> string.   If you think ethtool should print some helpful message instead
>>> of an empty string, please submit a patch for ethtool.
>>
>>
>> One question - will those actually be called via an ethtool path?  In my
>> poking about through the virtio code, I got the impression those modules
>> were for "other than networking" sorts of things.
>
> I don't know; I just assumed that was why you were adding them!  In
> other contexts such as dev_printk() this string would make even less
> sense.

Those were added to make sure there were no dangling references in the 
config_ops structure defined in those files and that the code calling 
through wouldn't go off into la-la land.  Perhaps it isn't necessary 
with Rusty's suggestion that I check ".bus_info" against NULL? But that 
is why those were there, and not simply the instance in virtio_pci.c. 
I'll spin a v2 regardless.

rick
