From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: Re: 82571EB: Detected Hardware Unit Hang
Date: Thu, 12 Jul 2012 02:52:22 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA891274F018D@ORSMSX102.amr.corp.intel.com>
References: <4FFA9B96.6040901@oracle.com> <4FFBDC50.5090800@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EE41F@ORSMSX102.amr.corp.intel.com>
	<4FFCCA22.8060006@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EEC8B@ORSMSX102.amr.corp.intel.com>
	<4FFCDA6C.8020708@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EED74@ORSMSX102.amr.corp.intel.com>
	<4FFCF314.6020400@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EEDD7@ORSMSX102.amr.corp.intel.com>
	<4FFD0908.6080506@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274EF8AD@ORSMSX102.amr.corp.intel.com>
	<4FFE3505.8060407@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4FFE3505.8060407@oracle.com>
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
>From: Joe Jin [mailto:joe.jin@oracle.com]
>Sent: Wednesday, July 11, 2012 7:23 PM
>To: Dave, Tushar N
>Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>kernel@vger.kernel.org
>Subject: Re: 82571EB: Detected Hardware Unit Hang
>
>On 07/12/12 02:51, Dave, Tushar N wrote:
>>
>> Joe,
>>
>> I see couple of errors in lspci output.
>> Device capability status register shows UnCorrectable PCIe error. This
>means there is certainly something went wrong. The only way to recover
>from Uncorrectable errors is reset.
>>
>> 	DevSta:	CorrErr- *UncorrErr+ FatalErr+ UnsuppReq+ AuxPwr+
>TransPend-
>>
>> Also AER sections in lspci output shows PCIe completion timeout.
>>
>> 	Capabilities: [100 v1] Advanced Error Reporting
>> 		UESta:	DLP- SDES- TLP- FCP- *CmpltTO+ CmpltAbrt- UnxCmplt-
>RxOF- MalfTLP+ ECRC- UnsupReq+ ACSViol-
>>
>> I suggest you should load AER driver and check for any error messages in
>log. Also please check any error message reported by system in BIOS log.
>Are there any machine check errors?
>>
>> When did you notice this issue? have 82571 ever been working before on
>this server?
>>
>> One more thing, Cache line size 256 is little unusual( I never seen this
>value before, mostly it's 64). Does BIOS settings have been changed? Are
>you using default BIOS setting?
>>
>
>I checked BIOS's log found the fault from the device, I changed "PCI-E
>Payload Size"
>from 256(default) to 128, now the device works.
>
>I compared lspci output found Address for data of MSI Capabilities's be
>changed:
>
>Old:
>        Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
>                Address: 00000000fee21000  Data: 40cb
>
>New:
>        Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
>                Address: 00000000fee24000  Data: 405c
>
>Mostly like it's a BIOS bug? please comments.
>
>Thanks,
>Joe

What is the exact error messages in BIOS log?


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
