From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH] network configs: disconnect network options from drivers
Date: Tue, 05 Apr 2005 11:46:45 -0700
Message-ID: <4252DD15.5020605@osdl.org>
References: <20050330234709.1868eee5.randy.dunlap@verizon.net> <20050331185226.GA8146@mars.ravnborg.org> <424C5745.7020501@osdl.org> <20050331203010.GA8034@mars.ravnborg.org> <4250B4C5.2000200@osdl.org> <20050404195051.GA12364@mars.ravnborg.org> <4251A830.5030905@osdl.org> <20050404215554.GA29170@mars.ravnborg.org> <4251C9A5.3020704@osdl.org> <20050405154538.GA9130@mars.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ioe-lkml@axxeo.de, matthew@wil.cx, lkml <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, hadi@cyberus.ca, cfriesen@nortel.com,
        tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: Sam Ravnborg <sam@ravnborg.org>
In-Reply-To: <20050405154538.GA9130@mars.ravnborg.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sam Ravnborg wrote:
> On Mon, Apr 04, 2005 at 04:11:33PM -0700, Randy.Dunlap wrote:
> 
>>- in Networking support, move Network testing and Netpoll
>>support to the end of the menu (basically put the devel.
>>tools toward the bottom of the menu)
> 
> Done
> 
> 
>>- I would rather not "hide" Amateur Radio, IrDA, and
>>Bluetooth in the Networking protocols area, but have them
>>near 802.1x and ATM in the top-level Networking support
>>menu.  How does that sound to you?
> 
> Done
> 
> I've made them with separate menu's that you have to enter to enable
> them.
> Also pushed out xfrm stuff to net/xfrm/Kconfig
> Several other small adjustments.
> In the Networking menu the submenu's are grouped in beginning and in the
> end now.
> 
> I thought of creating a Kconfig.netfilter for the common netfilter
> stuff. But in the end did not do it - felt there was plenty of new small
> files being created already.

It would make sense to isolate the netfilter options, but that can
be done later.
But you are right about "plenty of new small files."

I would move Frame Diverter (NET_DIVERT) from the end of the
net/core/Kconfig file to the top of the same file....
and then ship it.  :)


> Comments welcome.

Thanks for doing this.

-- 
~Randy
