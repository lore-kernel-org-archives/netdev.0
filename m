From: Borislav Petkov <bp@alien8.de>
Subject: Re: Lockdep warning
Date: Thu, 19 Dec 2013 15:02:21 +0100
Message-ID: <20131219140221.GA27143@pd.tnic>
References: <52B2F668.2030400@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jonas Bonn <jonas@southpole.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52B2F668.2030400@southpole.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 19, 2013 at 02:36:40PM +0100, Jonas Bonn wrote:
> Hi,
> 
> Here's a lockdep warning that I'm seeing on an MX28 with 3.13-rc4.
> This seems to happen as soon as the network link comes up...
> including the 'netdev' list here as the backtrace shows the FEC
> driver in the stacktrace.
> 
> Any advice on how to proceed to track this down appreciated...

In such situations I'd always search the net first, to see whether this
has been fixed already. Hint: try searching for "lockdep __udp4_lib_rcv"

:-)

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
