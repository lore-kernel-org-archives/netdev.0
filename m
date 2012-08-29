From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: Re: Intel 82574L hang when sending short ethernet
 packets at 100BaseT
Date: Wed, 29 Aug 2012 20:29:26 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA89130DB60AC@ORSMSX102.amr.corp.intel.com>
References: <87k3whtqci.fsf@kwong-desktop.i-did-not-set--mail-host-address--so-tickle-me>
	<061C8A8601E8EE4CA8D8FD6990CEA89130DB6077@ORSMSX102.amr.corp.intel.com>
	<CAK2bC5q5NcWj5vsmPB1GekUpON_R_mTWgkEAYBgBZSJZ30GcDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kelvie Wong <kwong@wurldtech.com>
To: Kelvie Wong <kelvie@ieee.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAK2bC5q5NcWj5vsmPB1GekUpON_R_mTWgkEAYBgBZSJZ30GcDg@mail.gmail.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: kelvie@gmail.com [mailto:kelvie@gmail.com] On Behalf Of Kelvie Wong
>Sent: Wednesday, August 29, 2012 1:17 PM
>To: Dave, Tushar N
>Cc: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net; Kelvie Wong
>Subject: Re: Intel 82574L hang when sending short ethernet packets at
>100BaseT
>
>On Wed, Aug 29, 2012 at 1:13 PM, Dave, Tushar N <tushar.n.dave@intel.com>
>wrote:
>>>
>>>Anyway, here is the reproduction tool:
>>
>> I see, "Adding enough zero pad bytes to bring frame size up to 17 bytes
>causes the reset to no longer occur" - Is this true?
>>
>> -Tushar
>
>Yes, that is correct. We have been doing that ourselves as a workaround.

I'm already aware of this issue on PCI/PCI-X parts and e1000 SF driver does have this WA implemented. The patch for upstream e1000 driver is submitted too which will be accepted soon.
I will check with team and see if we need similar WA for PCIe part(s)!

-Tushar 
------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
