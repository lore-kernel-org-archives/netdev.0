From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: linux-next: manual merge of the staging tree with the net tree
Date: Fri, 26 Aug 2011 00:35:56 -0500
Message-ID: <4E5730BC.6070604@lwfinger.net>
References: <20110826134705.0d5b6767777f0af2f8667731@canb.auug.org.au> <20110826043357.GA17686@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110826043357.GA17686@kroah.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/25/2011 11:33 PM, Greg KH wrote:
> On Fri, Aug 26, 2011 at 01:47:05PM +1000, Stephen Rothwell wrote:
>> Hi Greg,
>>
>> Today's linux-next merge of the staging tree got a conflict in
>> drivers/staging/rtl8192e/r8192E_core.c between commit afc4b13df143 ("net:
>> remove use of ndo_set_multicast_list in drivers") from the net tree and
>> commit 09505184ec3d ("staging: rtl8192e: Remove files that are not used")
>> from the staging tree.
>>
>> The latter removed the file, so I did that.
>
> Thanks, that should be the correct thing :)

I'm a little confused. The files deleted in 09505184ec3d are not used at all in 
the new rtl8192e. The only way it makes sense is you did not have the new 
version when the the error with r8192E_core.c occurred.

The error that was reported to me was 
"drivers/staging/rtl8192e/rtl_core.c:2917:2: error: unknown field 
'ndo_set_multicast_list' specified in initializer". The file rtl_core.c is 
needed with the new version. Yes, the names are quite confusing, which is part 
of the reason it took so long to delete the unused ones.

I have tested Stephan's patch and will send it to Greg with my SOB.

Larry
