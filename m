From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: remove bridge work
Date: Tue, 17 May 2016 11:39:23 -0400
Message-ID: <87r3d01yok.fsf@ketchup.mtl.sfl>
References: <1463186303-3139-1-git-send-email-vivien.didelot@savoirfairelinux.com> <8737plig1v.fsf@ketchup.mtl.sfl> <20160516.134823.1909596879203571371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch, f.fainelli@gmail.com,
	jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160516.134823.1909596879203571371.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

David Miller <davem@davemloft.net> writes:

> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Date: Fri, 13 May 2016 21:28:28 -0400
>
>> Hi David,
>> 
>> Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:
>> 
>>> Now that the bridge code defers the switchdev port state setting, there
>>> is no need to defer the port STP state change within the mv88e6xxx code.
>>> Thus get rid of the driver's bridge work code.
>>>
>>> This also fixes a race condition where the DSA layer assumes that the
>>> bridge code already set the unbridged port's STP state to Disabled
>>> before restoring the Forwarding state.
>>>
>>> As a consequence, this also fixes the FDB flush for the unbridged port
>>> which now correctly occurs during the Forwarding to Disabled transition.
>>>
>>> Fixes: 0bc05d585d38 ("switchdev: allow caller to explicitly request attr_set as deferred")
>>> Reported-by: Andrew Lunn <andrew@lunn.ch>
>>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> 
>> This patch doesn't apply to -net, only applies to net-next...
>> 
>> How should I handle that, do I resend a patch for net-next with the good
>> subject prefix, and a v2 for -net?
>
> I applied this to net-next, thanks.

Do we want to send this fix to -net as well?

Thanks,

        Vivien
