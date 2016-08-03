From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0071/1285] Replace numeric parameter like 0444 with macro
Date: Wed, 3 Aug 2016 15:47:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F50893F@AcuExch.aculab.com>
References: <20160802103831.18486-1-baolex.ni@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-atm-general@lists.sourceforge.net"
	<linux-atm-general@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"chuansheng.liu@intel.com" <chuansheng.liu@intel.com>
To: 'Baole Ni' <baolex.ni@intel.com>,
	"3chas3@gmail.com" <3chas3@gmail.com>,
	"tj@kernel.org" <tj@kernel.org>,
	"lenb@kernel.org" <lenb@kernel.org>,
	"x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160802103831.18486-1-baolex.ni@intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baole Ni
> Sent: 02 August 2016 11:39
> I find that the developers often just specified the numeric value
> when calling a macro which is defined with a parameter for access permission.
> As we know, these numeric value for access permission have had the corresponding macro,
> and that using macro can improve the robustness and readability of the code,
> thus, I suggest replacing the numeric parameter with the macro.
...
> -module_param(debug, ulong, 0644);
> +module_param(debug, ulong, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
...

If you're as old as I am the octal constant is easier to read!

	David
