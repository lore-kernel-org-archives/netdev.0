From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Is this 32-bit NCM?
Date: Tue, 2 Dec 2014 11:37:49 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1412021136170.2716@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com> <874mtl55ar.fsf@nemi.mork.no> <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com>
 <alpine.LNX.2.03.1411271932510.1548@gmail.com> <87ppc71xne.fsf@nemi.mork.no>,<alpine.LNX.2.03.1412012202480.1301@gmail.com> <B315C8AC-3B33-406B-A728-14F8FAAAE986@audiocodes.com> <547D37CA.7050506@audiocodes.com> <alpine.LNX.2.03.1412020729470.1351@gmail.com>
 <547D5F84.6020608@audiocodes.com> <alpine.LNX.2.03.1412020747360.1921@gmail.com> <547D6D7B.5090704@audiocodes.com> <E0C3DF2A36210C42B1AB4626A0E10F1FD949424C@aclmbx01.corp.audiocodes.com> <547D7243.80508@audiocodes.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1602404904-1417516670=:2716"
Cc: Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Midge Shaojun Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	"youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <547D7243.80508-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1602404904-1417516670=:2716
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

So, we can say that:
1 - They use 32-bit NCM if I am not wrong: so we where in the right direction 
Alex!
2 - The driver is "all-in-one": it supports QMI also, not only cdc_ncm.
3 - It #undefs some things from the headers and might be redefine them... 
mhm...


On Tue, 2 Dec 2014, Kevin Zhu wrote:

==Date: Tue, 2 Dec 2014 09:03:21
==From: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
==To: Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
==    Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==Cc: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>, Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
==    Midge Shaojun  Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
==    "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
==    "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
==    "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
==Subject: Re: Is this 32-bit NCM?
==
==Below is the content of the INF file oem54.inf.
==
==; Copyright (c) 2010,2011 Huawei Incorporated
==; Manufacturer: Huawei Incorporated
==;
==; CDC ECM & NCM driver
==;
==
==[Version]
==Signature="$WINDOWS NT$"
==Class=Net
==ClassGUID={4d36e972-e325-11ce-bfc1-08002be10318}
==Provider=%Mfg%
==DriverVer=04/14/2014,1.0.13.0
==CatalogFile=ew_wwanecm.cat
==
==[Manufacturer]
==%Mfg% = DeviceList,NTx86,NTamd64
==
==[SourceDisksNames]
==1 = %ew_wwanecm.DiskName%,,,""
==
==[SourceDisksFiles]
==ew_wwanecm.sys  = 1,,
==
==; For Win2K
==[DeviceList]
==%PNP21_HW_NetworkDesc%     = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_16
==%PNP21_VDF_NetworkDesc%    = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_46
==%PNP21_NetworkDesc%        = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_76
==
==%PNP21_HW_3G_NetworkDesc%  = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_07
==%PNP21_VDF_NetworkDesc%    = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_37
==%PNP21_NetworkDesc%        = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_67
==
==%PNP21_HW_NetworkDesc%     = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_11
==
==; for logo test
==%HUAWEI_NDISDeviceDesc%    = ew_wwanecm.ndi, USB\VID_12D1&PID_158F&MI_00
==
==; For WinXP and later
==[DeviceList.NTx86]
==%PNP21_HW_NetworkDesc%     = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_16
==%PNP21_VDF_NetworkDesc%    = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_46
==%PNP21_NetworkDesc%        = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_76
==
==%PNP21_HW_3G_NetworkDesc%  = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_07
==%PNP21_VDF_NetworkDesc%    = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_37
==%PNP21_NetworkDesc%        = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_67
==
==%PNP21_HW_NetworkDesc%     = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_11
==
==; for logo test
==%HUAWEI_NDISDeviceDesc% = ew_wwanecm.ndi, USB\VID_12D1&PID_158F&MI_00
==
==; For XP and later x64
==[DeviceList.NTamd64]
==%PNP21_HW_NetworkDesc%     = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_16
==%PNP21_VDF_NetworkDesc%    = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_46
==%PNP21_NetworkDesc%        = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_76
==
==%PNP21_HW_3G_NetworkDesc%  = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_07
==%PNP21_VDF_NetworkDesc%    = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_37
==%PNP21_NetworkDesc%        = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_67
==
==%PNP21_HW_NetworkDesc%     = ew_wwanecm.ndi,
==USB\VID_12D1&Subclass_03&Prot_11
==
==; for logo test
==%HUAWEI_NDISDeviceDesc% = ew_wwanecm.ndi, USB\VID_12D1&PID_158F&MI_00
==
==;-------------------------------------------------------------------------------
==
==; Virtual Ethernet Adapter
==;
==[ew_wwanecm.ndi]
==*IfType            = 243 ; IF_TYPE_WWANPP
==*MediaType         = 9; NdisMediumWirelessWan
==*PhysicalMediaType = 8 ; NdisPhysicalMediumWirelessWan
==EnableDhcp         = 0 ; DHCP Disabled
==Characteristics    = 0x84 ; NCF_HAS_UI | NCF_PHYSICAL
==BusType            = 15 ; if you specify NCF_PHYSICAL, you must specify
==bustype
==AddReg             = ew_wwanecm.Reg, ParamsPromiscuous, ParamsFrameType,
==ParamsIsNtb32, ParamsNTBInputSize, ParamsPacketsAccumulationTimeout,
==ParamsMaxNumOfDatagramsInNTB, FlowControlTimeOut,
==DisableAccumulationUpdate, WwanMbimEnable, NcmReinitializeEnable
==CopyFiles          = ew_wwanecm.CopyFiles
==
==
==[WWAN_AddReg]
==HKR,, Platform,0x00010001,0x3
==HKR,, WWAN,0x00010001,0x1
==HKR,, "SelectiveSuspendIdleTime", 0x00010001, 0x05
==[ew_wwanecm.ndi.Services]
==AddService      = %ServiceName%, 2, ew_wwanecm.Service, ew_wwanecm.EventLog
==
==[ew_wwanecm.ndi.HW]
==AddReg = WWAN_AddReg
==
==;-----------------------------------------------------------------------------
==
==;
==[ew_wwanecm.Reg]
==HKR,    ,                         BusNumber,           0, "0"
==HKR,    ,                         MPRadioState,        0x00010001,
==0x00000001       ;RadioState
==HKR, Ndi,                         Service,             0, "hwusb_wwanecm"
==HKR, Ndi\Interfaces,              UpperRange,          0, "flpp4" and
=="flpp6"
==HKR, Ndi\Interfaces,              LowerRange,          0, "ppip"
==
==[ParamsPromiscuous]
==;
==;    Should the physical NIC be set to Promiscuous mode
==;
==HKR, Ndi\Params\Promiscuous,     ParamDesc, , %Promiscuous%
==HKR, Ndi\Params\Promiscuous,     Default,  ,"0"
==HKR, Ndi\Params\Promiscuous,     type, ,      enum
==HKR, Ndi\Params\Promiscuous\enum,"1",  ,     %Promiscuous_Enable%
==HKR, Ndi\Params\Promiscuous\enum,"0",  , %Promiscuous_Disable%
==
==[ParamsFrameType]
==HKR, Ndi\Params\FrameType,     ParamDesc, 0, %FrameType%
==HKR, Ndi\Params\FrameType,     type,      0, enum
==HKR, Ndi\Params\FrameType,     Default,   0, "0"
==HKR, Ndi\Params\FrameType\enum,"1",       0, %FrameType_IP%
==HKR, Ndi\Params\FrameType\enum,"0",       0, %FrameType_Ethernet%
==
==[ParamsIsNtb32]
==HKR, Ndi\Params\IsNtb32,      ParamDesc, , %IsNtb32%
==HKR, Ndi\Params\IsNtb32,      Default, , "1"
==HKR, Ndi\Params\IsNtb32,      type, , enum
==HKR, Ndi\Params\IsNtb32\enum, "1", , "Yes"
==HKR, Ndi\Params\IsNtb32\enum, "0", , "No"
==
==[ParamsNTBInputSize]
==HKR, Ndi\Params\NTBInputSize,     ParamDesc, , %NTBInputSize%
==; If the following size is larger than the maximum allowed by the
==device, the
==; maximum value is used. 0 means to use the maximum allowed value of the
==device.
==HKR, Ndi\Params\NTBInputSize,     Default, , "0"
==HKR, Ndi\Params\NTBInputSize,     type, , dword
==
==[ParamsPacketsAccumulationTimeout]
==HKR, Ndi\Params\PacketsAccumulationTimeout,     ParamDesc, ,
==%PacketsAccumulationTimeout%
==; Unit of PacketsAccumulationTimeout is usecs. Default value is 20 us.
==HKR, Ndi\Params\PacketsAccumulationTimeout,     Default, , "20"
==HKR, Ndi\Params\PacketsAccumulationTimeout,     type, , dword
==
==[ParamsMaxNumOfDatagramsInNTB]
==HKR, Ndi\Params\MaxNumOfDatagramsInNTB,     ParamDesc, ,
==%MaxNumOfDatagramsInNTB%
==HKR, Ndi\Params\MaxNumOfDatagramsInNTB,     Default, , "64"
==HKR, Ndi\Params\MaxNumOfDatagramsInNTB,     type, , dword
==
==[FlowControlTimeOut]
==HKR, Ndi\Params\FlowControlTimeOut,     ParamDesc, , %FlowControlTimeout%
==HKR, Ndi\Params\FlowControlTimeOut,     Default, , "2800"
==HKR, Ndi\Params\FlowControlTimeOut,     type, , dword
==
==[DisableAccumulationUpdate]
==HKR, Ndi\Params\disable_accumulation_update,     ParamDesc, ,
==%DisableAccumulationUpdate%
==HKR, Ndi\Params\disable_accumulation_update,     Default, , "0"
==HKR, Ndi\Params\disable_accumulation_update,     type, , dword
==
==[WwanMbimEnable]
==HKR, Ndi\Params\WwanMbimEnable, ParamDesc, , %WwanMbimEnable%
==HKR, Ndi\Params\WwanMbimEnable, Default, , "0"
==HKR, Ndi\Params\WwanMbimEnable, type, , dword
==
==[NcmReinitializeEnable]
==HKR, Ndi\Params\NcmReinitializeEnable, ParamDesc, , %NcmReinitializeEnable%
==HKR, Ndi\Params\NcmReinitializeEnable, Default, , "1"
==HKR, Ndi\Params\NcmReinitializeEnable, type, , dword
==
==;-----------------------------------------------------------------------------
==
==; DestinationDirs
==;
==[DestinationDirs]
==ew_wwanecm.CopyFiles = 12
==
==[ew_wwanecm.CopyFiles]
==ew_wwanecm.sys,,,0x6  ;COPYFLG_NOSKIP | COPYFLG_NOVERSIONCHECK
==;-----------------------------------------------------------------------------
==
==; Driver and Service Section
==;
==
==[ew_wwanecm.Service]
==ServiceType     = 1 ;%SERVICE_KERNEL_DRIVER%
==StartType       = 3 ;%SERVICE_DEMAND_START%
==ErrorControl    = 1 ;%SERVICE_ERROR_NORMAL%
==ServiceBinary   = %12%\ew_wwanecm.sys
==LoadOrderGroup  = NDIS
==AddReg          = ew_wwanecm.Service.Reg
==
==[ew_wwanecm.Service.Reg]
==HKR, , TextModeFlags,    0x00010001, 0x0001
==HKR, Parameters, DebugLevel, 0x00010001, 1
==HKR, Parameters, WwanLogoTestOn, 0x00010001, 0
==
==[ew_wwanecm.EventLog]
==AddReg = ew_wwanecm.AddEventLog.Reg
==
==[ew_wwanecm.AddEventLog.Reg]
==HKR, , EventMessageFile, 0x00020000, "%%SystemRoot%%\System32\netevent.dll"
==HKR, , TypesSupported,   0x00010001, 7
==
==;-----------------------------------------------------------------------------
==
==; Localizable Strings
==;
==[Strings]
==Mfg = "HUAWEI"
==
==HUAWEI_NDISDeviceDesc      = "HUAWEI Mobile Connect - Network Adapter"
==
==;PNP2.1 Device descriptor
==PNP21_HW_3G_NetworkDesc = "HUAWEI Mobile Connect - 3G Network Card"
==PNP21_HW_NetworkDesc = "HUAWEI Mobile Connect - Network Card"
==PNP21_NetworkDesc = "Mobile Connect - Network Card"
==PNP21_VDF_NetworkDesc = "Vodafone Mobile Broadband Network Adapter
==(Huawei)"
==
==ew_wwanecm.DiskName        = "DriverCore Installation Disk"
==Promiscuous                = "Set the physical NIC to promiscuous mode"
==Promiscuous_Disable        = "Disable"
==ServiceName                = "hwusb_wwanecm"
==Promiscuous_Enable         = "Enable"
==FrameType                  = "Frame Type in driver-device communications"
==FrameType_Ethernet         = "Ethernet"
==FrameType_IP               = "IP"
==
==IsNtb32                    = "32bit mode"
==NTBInputSize               = "NTB input size"
==PacketsAccumulationTimeout = "Packets Accumulation Timeout [usec]"
==MaxNumOfDatagramsInNTB     = "Maximum number of datagrams in NTB"
==FlowControlTimeout         = "Flow Control timeout interval in ms"
==DisableAccumulationUpdate  = "Flag to disable NCM accumulation auto
==updation"
==WwanMbimEnable             = "Flag to enable WWAN MBIM function"
==NcmReinitializeEnable      = "Flag to enable NCM reinitialize after resume"
==
==Regards,
==Kevin
==
==On 12/02/2014 03:45 PM, Eli Britstein wrote:
==> Outlook blocked the attachment. Please zip it and resend.
==>
==> Thanks,
==> Best regards,
==>
==> Eli Britstein
==> SW Team Leader and Project Manager
==> MP2xx Residential Gateways
==>
==> Tel:         +972-3-9764148
==> Mobile:  +972-54-2312677
==> Fax:        +972-3-9764040
==> Email:      Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org
==> Web:        www.audiocodes.com
==>
==>
==>
==> -----Original Message-----
==> From: Kevin Zhu
==> Sent: Tuesday, December 02, 2014 9:44
==> To: Enrico Mioso
==> Cc: Eli Britstein; Bjørn Mork; Alex Strizhevsky; Midge Shaojun Tan; youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
==> Subject: Re: Is this 32-bit NCM?
==>
==> Hi all,
==>
==> Here's the registry from windows 7. Attached. One parameter that might be interesting is MaxNumOfDatagramInNTB, which is 64. I wonder if it has something to do with MaxDatagramSize. Can someone also check the registry, in case I missed something?
==>
==> Regards,
==> Kevin
==>
==> On 12/02/2014 02:49 PM, Enrico Mioso wrote:
==>> Can you try to look at Windows registry keys based on the INF file as
==>> suggested or would this be a problem for you?
==>> And... if you have any Huawei manutal talking about it: even device's
==>> ^DSFLOWRPT might be useful to some extent, but ... this is only just a
==>> note in case we don't find anything else.
==>> Regards ... and good day to all of you, Enrico
==>>
==>>
==>> On Tue, 2 Dec 2014, Kevin Zhu wrote:
==>>
==>> ==Date: Tue, 2 Dec 2014 07:43:24
==>> ==From: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
==>> ==To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==>> ==Cc: Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>, Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
==>> ==    Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
==>> ==    Midge Shaojun  Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
==>> ==    "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
==>> ==    "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
==>> ==    "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
==>> ==Subject: Re: Is this 32-bit NCM?
==>> ==
==>> ==I also tried to define CDC_NCM_DPT_DATAGRAMS_MAX as 1 to eliminate
==>> the ==paddings, but it did not work either, not even DHCP.
==>> ==
==>> ==Regards,
==>> ==Kevin
==>> ==
==>> ==On 12/02/2014 02:32 PM, Enrico Mioso wrote:
==>> ==> Hi again Eli,
==>> ==> Hi Kevin,
==>> ==> Hi everyone...
==>> ==>
==>> ==> As I understand it anyway - the distinction here tends not to be
==>> between ==> different types of packets.
==>> ==> It tends to be between received and sent packet.
==>> ==> We are not able to generate packets that the device retains valid.
==>> ==> If you manually configure the IP the device would have assigned
==>> you via DHCP, ==> your system will start answering ARP request, saying
==>> that the host with IP ==> aa.bb.cc.dd is at aa:bb:cc:dd:ee (using the MC address of the dongle).
==>> ==> However, the other host (gateway) will never know that. Indeed,
==>> it'll continue ==> asking who-is at aa.bb.cc.dd ?
==>> ==> At least, this is the situation I observed in the test system.
==>> ==>
==>> ==>
==>> ==> On Tue, 2 Dec 2014, Kevin Zhu wrote:
==>> ==>
==>> ==> ==Date: Tue, 2 Dec 2014 04:53:53
==>> ==> ==From: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org> ==> ==To: Eli
==>> Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
==>> ==> ==    Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==>> ==> ==Cc: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>, Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
==>> ==> ==    Midge Shaojun  Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
==>> ==> ==    "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
==>> ==> ==    "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
==>> ==> ==    "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
==>> ==> ==Subject: Re: Is this 32-bit NCM?
==>> ==> ==
==>> ==> ==Hi,
==>> ==> ==
==>> ==> ==The DHCP packets have the maximum size of dwNtbOutMaxSize=16384,
==>> while ==> ==the other packets are less than that. However, the DHCP
==>> queries are not ==> ==replied in time either, there's always some delay.
==>> ==> ==
==>> ==> ==By the way, though the device claims to support
==>> GET_MAX_DATAGRAM_SIZE, ==> ==but it returns error when the host sends
==>> this command to it. I disabled ==> ==this command in NCM driver and tried, but it's the same result.
==>> ==> ==
==>> ==> ==Regards,
==>> ==> ==Kevin
==>> ==> ==
==>> ==> ==On 12/02/2014 06:02 AM, Eli Britstein wrote:
==>> ==> ==> Hi Enrico and all,
==>> ==> ==>
==>> ==> ==> Maybe I missed something but what is the difference by the driver point of view between the dhcp discover and request (that are ok) to others (like arp, that is nok)?
==>> ==> ==> Maybe we can trace to compare them?
==>> ==> ==>
==>> ==> ==> Sent from my iPhone
==>> ==> ==>
==>> ==> ==>> On 1 בדצמ 2014, at 23:11, "Enrico Mioso" <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
==>> ==> ==>>
==>> ==> ==>> So ... I have two ideas left for now.
==>> ==> ==>> We know for sure the problem is in the way we TX frames, not
==>> the way we RX them ==> ==>> (the way we send, generate them, not the way we receive them).
==>> ==> ==>> Si I have two ideas, and I ask for help from the Linux-usb
==>> mailing list for ==> ==>> this first one.
==>> ==> ==>>
==>> ==> ==>> 1 - Does a wayexist to "replay" traffic crom a usb capture?
==>> ==> ==>> We might try to take the usb frames generated by Windows, and
==>> send them to the ==> ==>> device to see if there is any reaction. It
==>> should not be science fiction, I saw ==> ==>> them do that in the eciadsl old project.
==>> ==> ==>> 2 - The huawei ndis driver: does it work with these devices?
==>> ==> ==>> It should be a little bit out-dated now (at least in terms of
==>> dates, it might ==> ==>> work as well): the code is A LOT but, just in
==>> case, to see if there is any ==> ==>> chances it'll work. It remains
==>> to be seen in which kernels it can actually ==> ==>> compile again.
==>> ==> ==>>
==>> ==> ==>> If this works we might analyse what's happening and try to debug this out.
==>> ==> ==>> But I really would like this to work in the cdc_ncm driver + huawei_cdc_ncm.
==>> ==> ==>> Thank you.
==>> ==> ==This email and any files transmitted with it are confidential material. They are intended solely for the use of the designated individual or entity to whom they are addressed. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, use, distribution or copying of this communication is strictly prohibited and may be unlawful.
==>> ==> ==
==>> ==> ==If you have received this email in error please immediately
==>> notify the sender and delete or destroy any copy of this message ==>
==>> == ==This email and any files transmitted with it are confidential material. They are intended solely for the use of the designated individual or entity to whom they are addressed. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, use, distribution or copying of this communication is strictly prohibited and may be unlawful.
==>> ==
==>> ==If you have received this email in error please immediately notify
==>> the sender and delete or destroy any copy of this message ==
==>
==This email and any files transmitted with it are confidential material. They are intended solely for the use of the designated individual or entity to whom they are addressed. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, use, distribution or copying of this communication is strictly prohibited and may be unlawful.
==
==If you have received this email in error please immediately notify the sender and delete or destroy any copy of this message
==
--8323328-1602404904-1417516670=:2716--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
