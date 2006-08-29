From: Mohamed Abbas <mabbas@linux.intel.com>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Tue, 29 Aug 2006 15:28:46 -0700
Message-ID: <44F4BF9E.4040309@linux.intel.com>
References: <44F356DF.9000000@linux.intel.com> <200608281417.39948.flamingice@sourmilk.net> <20060829175544.GI1701@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org,
	jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:43186 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S965043AbWH2W2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 18:28:48 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060829175544.GI1701@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:

>On Mon, Aug 28, 2006 at 02:17:34PM -0700, Michael Wu wrote:
>
>  
>
>>It would be helpful if you inlined your patches instead of attaching them next 
>>time.
>>    
>>
>
>Agreed.
>
>  
>
>>I'm not comfortable with using the name for this purpose.
>>    
>>
>
>And agreed. wireless.h has this to say about SIOCGIWNAME:
>
>#define SIOCGIWNAME     0x8B01          /* get name == wireless protocol */
>/* SIOCGIWNAME is used to verify the presence of Wireless Extensions.
> * Common values : "IEEE 802.11-DS", "IEEE 802.11-FH", "IEEE 802.11b"...
> * Don't put the name of your driver there, it's useless. */
>
>
>The proposed use here is against this and should not be applied.
>SIOCGIWAP can be used to indicate association status and SIOCGIWTXPOW
>can be used to indicate whether TX is powered which is quite close to
>radio off indication.
>
>  
>
to associated to a network i do the following
#iwconfig wlan0 essid {some name} channel X ap {bssid of the AP}
after I issues this command  SIOCGIWAP will always report the bssid no 
matter what the status of our link.
