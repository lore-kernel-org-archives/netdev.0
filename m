From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Thu, 08 Jun 2006 13:35:28 -0700
Message-ID: <44888A10.4010207@intel.com>
References: <44886381.9050506@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964988AbWFHUgD@vger.kernel.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
In-Reply-To: <44886381.9050506@goop.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:
> I've been trying to get suspend/resume working well on my new laptop.  
> In general, netconsole has been pretty useful for extracting oopses and 
> other messages, but it is of more limited help in debugging the actual 
> suspend/resume cycle.  The problem looks like the e1000 driver won't 
> suspend while netconsole is using it, so I have to rmmod/modprobe 
> netconsole around the actual suspend/resume.
> 
> This is a big problem during resume because the screen is also blank, so 
> I get no useful clue as to what went wrong when things go wrong.  I'm 
> wondering if there's some way to keep netconsole alive to the last 
> possible moment during suspend, and re-woken as soon as possible during 
> resume.  It would be nice to have a clean solution, but I'm willing to 
> use a bletcherous hack if that's what it takes.
> 
> Any ideas?

Have you tried using different cards/drivers? This might or might not be 
either a netconsole problem (generic) or driver related (which could impact 
other drivers too).

 From the top of my head I don't see any reason why the e1000 shouldn't handle 
the suspend event - but mind you that a fix for e1000/WoL impacting shutdown 
handlers was only recently added. Which kernels does this impact?

Auke
