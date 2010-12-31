From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Do not use legacy PCI power management
Date: Fri, 31 Dec 2010 11:14:52 -0800 (PST)
Message-ID: <20101231.111452.102554570.davem@davemloft.net>
References: <201012261944.32517.rjw@sisk.pl>
	<20101231101521.598d41c6@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
        shemminger@linux-foundation.org
To: shemminger@vyatta.com
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <20101231101521.598d41c6@s6510>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 31 Dec 2010 10:15:21 -0800

> On Sun, 26 Dec 2010 19:44:32 +0100
> "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> 
>> From: Rafael J. Wysocki <rjw@sisk.pl>
>> 
>> The sky2 driver uses the legacy PCI power management, so it has to do
>> some PCI-specific things in its ->suspend() and ->resume() callbacks,
>> which isn't necessary and should better be done by the PCI
>> sybsystem-level power management code.  Moreover, it uses
>> device_set_wakeup_enable() incorrectly (that function should be
>> used when the WoL setting is changed rather than during suspend).
>> 
>> Convert sky2 to the new PCI power management framework and make it
>> let the PCI subsystem take care of all the PCI-specific aspects of
>> device handling during system power transitions.
>> 
>> Tested on a desktop machine with a Marvell 88E8056 PCI-E adapter.
>> 
>> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> 
> Tested on 88E8055 (laptop), my desktop machines have video issues and
> won't suspend/resume.
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
