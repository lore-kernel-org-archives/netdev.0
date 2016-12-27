From: Robert Grasso <robert.grasso@modulonet.fr>
Subject: Re: driver r8169 suddenly failed
Date: Tue, 27 Dec 2016 08:33:29 +0100
Message-ID: <0d1c7e06-5c4a-b60c-6f7b-afe73532a57a@modulonet.fr>
References: <428aa40c-e313-99ae-d3ae-97b6a5ef40e4@modulonet.fr>
 <20161227001248.GA20172@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
        netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.tech.numericable.fr ([82.216.111.37]:50792 "EHLO
        smtp1.tech.numericable.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbcL0Hdg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 02:33:36 -0500
In-Reply-To: <20161227001248.GA20172@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for your quick answer ! Allow me some days for this test :

1 - I am at work these days
2 - it has been a while since I have dealt with custom kernels, I am a 
bit rusty, it will be good to review this topic

-- 
Robert Grasso
@home
---
UNIX was not designed to stop you from doing stupid things, because
   that would also stop you from doing clever things. -- Doug Gwyn

On 27/12/2016 01:12, Francois Romieu wrote:
> Robert Grasso <robert.grasso@modulonet.fr> :
> [dhcp snafu]
>> First of all, can you confirm that I am doing right in posting to you
>> (addresses found in README.Debian) ?
> It isn't completely wrong.
>
>> If I do, can you help ? I am not very proficient with Ethernet, and I am not
>> able to figure out what my provider changed : their hotline is
>> underqualified, they are just able to tell that "the signal on the line is
>> ok".
> You're spoiled. It is more than decent for a company whose core business
> used to sell cable TV.
>
>> But if you want me to run various tests, try new versions, I would be
>> glad to do so : I would appreciate if I could salvage this Shuttle.
> Please try a recent stable vanilla kernel and send a complete dmesg
> from boot. I need to identify the specific 816x chipset.
>
> Then record some traffic:
>
> # touch gonzo.pcap && tshark -w gonzo.pcap -i eth1
>
> It should only exhibit small outgoing packets but, well, one never knows.
>
> Check the leds activity to be sure that the network interfaces have not
> been renumbered.
>
> Use ethtool to check that tso is disabled. If it isn't, disable it.
>
