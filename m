From: Alejandro Bonilla Beeche <abonilla@linuxwireless.org>
Subject: Re: ancient ieee80211/ipw2200 drivers in recent kernel (2.6.14)
Date: Tue, 01 Nov 2005 20:44:06 -0700
Message-ID: <43683606.4060703@linuxwireless.org>
References: <873bmg9sym.fsf@vertex.dottedmag.net> <20051102020903.GG29803@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mikhail Gusarov <dottedmag@dottedmag.net>,
	debian-kernel@lists.debian.org, NetDev <netdev@vger.kernel.org>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <bounce-debian-kernel=glddk-debian-kernel=m.gmane.org@lists.debian.org>
To: Horms <horms@verge.net.au>
In-Reply-To: <20051102020903.GG29803@verge.net.au>
Resent-Message-ID: <MZ-pd.A.xtE.WxCaDB@murphy>
List-Post: <mailto:debian-kernel@lists.debian.org>
List-Help: <mailto:debian-kernel-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-kernel-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-kernel-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Horms wrote:

>On Tue, Nov 01, 2005 at 11:30:09PM +0600, Mikhail Gusarov wrote:
>  
>
>>Hello,
>>
>>I've encountered the problem with 2.6.14 kernels: they are shipped
>>with ancient version of ipw2200 drivers (1.0.0 while current version
>>is 1.0.7) and ancient version of ieee80211 subsystem (copyrighted as
>>2004, so also outdated).
>>
>>This breaks compilation of module from ipw2200-source package (because
>>it links against in-kernel ieee80211).
>>    
>>
The .deb will need to run the remove-old script included in the new 
versions of the driver/stack.

>
>I assume the problem you are seeing is a headers problem.
>
>  
>
>>Is there way to modularize builds to exclude ieee80211 or just disable
>>it (along with ipw2200) because it is outdated and current vesion is
>>shipped in ieee80211-source package?
>>    
>>
>
>Probably the best place to start is to ping netdev to find out if
>there are any plans to update IPW2200 in Linus's tree. I've CCed
>that list, hopefully someone can shed some light on this.
>
>  
>
Not really. Basically, only stable versions of the driver make it into 
Mainline, and currently 1.0.8 is being tested to move into mainline 
(first -mm, then when people decide move to Linus)

Basically, when installing 1.0.8 and ieee80211-1.1.5, the .deb packages 
or whatever will need to run the remove-old script that is included in 
the source in order to make the new versions compile.

.Alejandro
