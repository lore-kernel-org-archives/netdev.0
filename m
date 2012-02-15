From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] r8169: Enable WOL from Magic Packet by
	default
Date: Tue, 14 Feb 2012 22:37:46 -0500 (EST)
Message-ID: <20120214.223746.419009242484406948.davem@davemloft.net>
References: <1329244079-27842-1-git-send-email-snanda@chromium.org>
	<20120215001342.GA11453@electric-eye.fr.zoreil.com>
	<CANMivWax5jGNJLkjZWi2F5iaM+bnK0Ti1qZzQx4CGgkzeQqt7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	hayeswang@realtek.com, romieu@fr.zoreil.com
To: snanda@chromium.org
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <CANMivWax5jGNJLkjZWi2F5iaM+bnK0Ti1qZzQx4CGgkzeQqt7Q@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/linux-pm/>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Sameer Nanda <snanda@chromium.org>
Date: Tue, 14 Feb 2012 17:00:04 -0800

> On Tue, Feb 14, 2012 at 4:13 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
>> Sameer Nanda <snanda@chromium.org> :
>>> Set the WOL config registers to only enable WOL from magic packet by
>>> default. Without this change in place, the WOL config register
>>> settings on warm reboot come up in an inconsistent state since these
>>> registers don't get reset on a warm reboot.
>>
>> I am not completely convinced, especially as the change of behavior
>> could be noticed.
> 
> Agreed that this change could be noticed.  Maybe a module parameter
> might be a better way to handle this?

Please no random module parameters, something ethtool based is
what you should shoot for.
