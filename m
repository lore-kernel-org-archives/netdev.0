From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 0/59] Cleanup sysctl
Date: Tue, 16 Jan 2007 10:58:10 -0800
Message-ID: <45AD2042.9090701@zytor.com>
References: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com>	<45AD02FF.605@zytor.com> <m164b6den7.fsf@ebiederm.dsl.xmission.com>	<45AD1AD7.7030804@zytor.com> <m1ac0iby5q.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	Tony Luck <tony.luck@intel.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751021AbXAPS6q@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1ac0iby5q.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
>>>
>> With "architectural" I mean "guaranteed to be stable" (as opposed to
>> "incidental").  Sorry for the confusion.
> 
> Ok.  Then largely we are in agreement.  To implement that the rule is simple.
> If it isn't CTL_UNNUMBERED and the number is in Linus's tree, it is
> our responsibility to never change the meaning of that number.
> 
> If a new sysctl entry is introduced it should be CTL_UNNUMBERED until
> it reaches Linus's tree to avoid conflicts.
> 
> There is simply no point in having any kind of support for numbers
> whose meanings can change.
> 
> Which is why I removed the few cases of binary number duplication I
> found.
> 

Agreed.  *Furthermore*, if the number isn't in <linux/sysctl.h> it 
shouldn't exist anywhere else, either.

	-hpa
