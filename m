From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH] network configs: disconnect network options from drivers
Date: Mon, 04 Apr 2005 16:11:33 -0700
Message-ID: <4251C9A5.3020704@osdl.org>
References: <20050330234709.1868eee5.randy.dunlap@verizon.net> <20050331185226.GA8146@mars.ravnborg.org> <424C5745.7020501@osdl.org> <20050331203010.GA8034@mars.ravnborg.org> <4250B4C5.2000200@osdl.org> <20050404195051.GA12364@mars.ravnborg.org> <4251A830.5030905@osdl.org> <20050404215554.GA29170@mars.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ioe-lkml@axxeo.de, matthew@wil.cx, lkml <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, hadi@cyberus.ca, cfriesen@nortel.com,
        tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: Sam Ravnborg <sam@ravnborg.org>
In-Reply-To: <20050404215554.GA29170@mars.ravnborg.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sam Ravnborg wrote:
> 
>>>- Move submenu to the top
>>>- Rename top menu to "Networking" and located it just before
>>>"File systems"
>>
>>I still prefer Networking to come before Device Drivers FWIW.
>>Just makes some kind of hierarchical sense to me.
> 
> Moved up as suggested.
> 
> 
>>I propose that the new file net/atm/Kconfig be sourced somewhere.
> 
> Thanks, I have missed that one - added just before wanrouter.
>  
> 
>>I'll look at it more to see if I have any other comments.
> 
> OK. I will await and post an updated patch if you do not beat me.

Sam,
Here are a few more suggestions for you to consider.

- in Networking support, move Network testing and Netpoll
support to the end of the menu (basically put the devel.
tools toward the bottom of the menu)

- I would rather not "hide" Amateur Radio, IrDA, and
Bluetooth in the Networking protocols area, but have them
near 802.1x and ATM in the top-level Networking support
menu.  How does that sound to you?

Thanks.

-- 
~Randy
