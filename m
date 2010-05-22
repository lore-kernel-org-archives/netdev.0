From: Julien Vehent <julien@linuxwall.info>
Subject: Re: QoS weirdness : HTB accuracy
Date: Sat, 22 May 2010 16:29:21 +0200
Message-ID: <e6bd0cff8dafc8b3af0760facb5fdc8c@localhost>
References: <067c83163988908ef546d7ff7f560a17@localhost>
 <4BF32BB0.7010700@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	netfilter <netfilter@vger.kernel.org>
To: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4BF32BB0.7010700@redfish-solutions.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 May 2010 18:07:12 -0600, "Philip A. Prindeville"
<philipp_subx@redfish-solutions.com> wrote:
> 
> Sorry for the late response:  could this be an "aliasing" issue caused
> by sampling intervals (granularity)?
> 
> -Philip

I was, in fact, an error in my ruleset. I had put the 'linklayer atm' at
both the branch and leaf levels, so the overhead was computed twice,
creating those holes in the bandwidth.

Julien
