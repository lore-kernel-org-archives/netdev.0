From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6 - bisected
Date: Sun, 01 Mar 2009 07:21:39 +0100
Message-ID: <49AA2973.7040209@krogh.cc>
References: <491FEAD5.4090205@krogh.cc> <49A7B17F.2020408@krogh.cc> <16084.1235752119@death.nxdomain.ibm.com> <49A84802.7030502@krogh.cc> <30478.1235766943@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@redhat.com>, aowi@novozymes.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756006AbZCAGV7@vger.kernel.org>
In-Reply-To: <30478.1235766943@death.nxdomain.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Jesper Krogh <jesper@krogh.cc> wrote:
> 
>> Jay Vosburgh wrote:
>>> Jesper Krogh <jesper@krogh.cc> wrote:
>>> [...]
>>>> The offending commit seems to be:
>>>>
>>>> A test with a fresh 2.6.29-rc6 revealed that the problem has been fixed
>>>> subsequently.. but still exists in 2.6.27-newest.  (havent tested
>>>> 2.6.28-newest yet).
>>>>
>>>> Any ideas of what the "fixing" commit is .. or should that also be
>>>> bisected?
>>> 	I went back and looked at your earlier mail.  Since you're using
>>> 802.3ad mode, my first guess would be this commit:
>>>
>>> commit fd989c83325cb34795bc4d4aa6b13c06f90eac99
 >
> 	I'll compile 2.6.28.7 here and see if it works for me.

I appreciate that you spend time on it, but my feeling is that it 
definately isn't reproducible in all environments (otherwise we would
probably have seen a large cry by now).

I'm trying to bisect the "fix" down and hope that'll tell us something 
more.

If you do the test, remember, that it is not like "bonding isn't 
working". It just fails to initialize correctly at bootup and doesnt get 
  the link state by itself. Subsequently doing a /etc/init.d/networking 
restart brigs it correct up.

-- 
Jesper
