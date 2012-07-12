From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: 82571EB: Detected Hardware Unit Hang
Date: Thu, 12 Jul 2012 18:19:49 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA891274F0ACC@ORSMSX102.amr.corp.intel.com>
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
 <061C8A8601E8EE4CA8D8FD6990CEA891274F018D@ORSMSX102.amr.corp.intel.com>
 <4FFE3D27.7020500@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F01BE@ORSMSX102.amr.corp.intel.com>
 <4FFE40A9.4060807@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F02D7@ORSMSX102.amr.corp.intel.com>
 <4FFE6BB9.4060106@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274F033B@ORSMSX102.amr.corp.intel.com>
 <4FFE787B.9050201@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FFE787B.9050201@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Joe Jin [mailto:joe.jin@oracle.com]
>Sent: Thursday, July 12, 2012 12:11 AM
>To: Dave, Tushar N
>Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>kernel@vger.kernel.org
>Subject: Re: 82571EB: Detected Hardware Unit Hang
>
>On 07/12/12 14:41, Dave, Tushar N wrote:
>>> On 07/12/12 13:57, Dave, Tushar N wrote:
>>>>> -----Original Message-----
>>>>> From: Joe Jin [mailto:joe.jin@oracle.com]
>>>>> Sent: Wednesday, July 11, 2012 8:13 PM
>>>>> To: Dave, Tushar N
>>>>> Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>>>>> kernel@vger.kernel.org
>>>>> Subject: Re: 82571EB: Detected Hardware Unit Hang
>>>>>
>>>>> On 07/12/12 11:07, Dave, Tushar N wrote:
>>>>>>> -----Original Message-----
>>>>>>> From: Joe Jin [mailto:joe.jin@oracle.com]
>>>>>>> Sent: Wednesday, July 11, 2012 7:58 PM
>>>>>>> To: Dave, Tushar N
>>>>>>> Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>>>>>>> kernel@vger.kernel.org
>>>>>>> Subject: Re: 82571EB: Detected Hardware Unit Hang
>>>>>>>
>>>>>>> On 07/12/12 10:52, Dave, Tushar N wrote:
>>>>>>>> What is the exact error messages in BIOS log?
>>>>>>>
>>>>>>> Error message from BIOS event log:
>>>>>>> 07/12/12 05:54:00
>>>>>>>    PCI Express Non-Fatal Error
>>>>>>>
>>>>>>> Thanks,
>>>>>>> Joe
>>>>> Hi Tushar,
>>>>>
>>>>> Please find eeprom from attachment.
>>>>
>>>> Do you have lspci -vvv dump of entire system before and after issue
>>> occurs? If you have can you send it to me?
>>>>
>>>
>> Sorry but I meant the full lspci -vvv of *entire system* before and
>after issue occurs and not of 82571 only.
>>
>
>Before:
>=======
>00:00.0 Host bridge: Intel Corporation 5500 I/O Hub to ESI Port (rev 22)
>	Subsystem: Oracle Corporation Device 5352

Joe, thanks for all the data.
You said you have changed max payload size and issue stop occurring. How did you change it? Where did you make that change in BIOS or EEPROM or in PCIe config space?
Also please send me the full dmesg of entire system after you change max payload size.

Thanks.
