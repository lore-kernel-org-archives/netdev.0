From: Mirko Lindner <mlindner@syskonnect.de>
Subject: Re: [PATCH] sk98lin: Driver update v7.09
Date: Fri, 29 Oct 2004 19:43:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4182812D.8020407@syskonnect.de>
References: <417907C1.6050407@syskonnect.de> <20041027102519.0fc3c7a9@guest-251-240.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, rroesler@syskonnect.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041027102519.0fc3c7a9@guest-251-240.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen,

thank You for the help! Should we help you in any case to check or 
change the defines?

We have the problem that the Linux driver consists of multiple files 
which are also used for other drivers running on other OSes
(e.g. Sun, HP-UX, MacOS X, *BSD, Windows, PXE, AIX, Unixware...).

This is for instance the reason why we must use redefines for the
different data types (e.g. SK_U32). Can you please explain what you mean 
with "UglyReDefineTheWorld"? Are there any special defines you do not 
like? I am wondering why the style plays such an important role when 
looking at the driver source. I am not sure what redefines you are 
referring to, but the datatype redefines for example have been in the 
kernel tree for years without any complains.

If you could send us a list about the requested changes you'd like to 
perform, we can help you or provide additional support. We would really 
appreciate it, if you could inform us in advance about those changes,
because the driver was tested extensively in our test&verification 
department and by a considerably amount of OEM vendors. Changing now 
parts of the code may break the driver functionality or the 
functionality of the driver files used on other OSes.

Cheers
  Mirko


Stephen Hemminger wrote:
> On Fri, 22 Oct 2004 15:14:41 +0200
> Mirko Lindner <mlindner@syskonnect.de> wrote:
> 
> 
>>Hi dev-list,
>>Hi Jeff,
>>
>>here is the new version (v7.09) from our sk98lin driver for Kernel 2.6. 
>>Sorry for this huge patch but this version has a lot of new functions 
>>and changes. The driver was tested by our Test & Verification group and 
>>our OEM customers and include all kernel changes during the latest 
>>kernel release.
>>
>>Please send me an email if you like a version of the driver for kernel 
>>2.4 or if you have any problems or questions.
>>
>>The new patch for BK version 2.6.9 bk6 can be find at:
>>http://www.syskonnect.de/support/temp/sk98lin_v7.09_2.6.9-bk6_patch
> 
> 
> Since you won't...
> I'll break this up in pieces (and merge in my changes), and get
> rid of the UglyReDefineTheWorld style.
> 
> 
