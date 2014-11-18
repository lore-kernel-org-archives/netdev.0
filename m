From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/1 net-next] wireless: remove unnecessary sizeof(u8)
Date: Tue, 18 Nov 2014 10:12:26 -0600
Message-ID: <546B6FEA.1090405@lwfinger.net>
References: <1415998553-12636-1-git-send-email-fabf@skynet.be>	<CAGRGNgWqjsDu_mQK=_agBWjOequb4b7ffgCuxRH=9d72grDYtQ@mail.gmail.com>	<828430032.148603.1416203787175.open-xchange@webmail.nmp.skynet.be>	<20141117133618.GC3511@tuxdriver.com> <CAFpvzpxYrjR_tSF99iosMGZTAmt=_6o_aA+iYjNhxRGJ9aJ6oA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Fabian Frederick <fabf@skynet.be>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Johannes Berg <johannes.berg@intel.com>,
	Julian Calaby <julian.calaby@gmail.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	b43-dev <b43-dev@lists.infradead.org>,
	netdev <netdev@vger.kernel.org>
To: Gheorhios <gheorhios@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFpvzpxYrjR_tSF99iosMGZTAmt=_6o_aA+iYjNhxRGJ9aJ6oA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/18/2014 07:34 AM, Gheorhios wrote:
> Anyone could gently send the link for downloading B43 linux drivers for
> this procedure?
>
>
>
> Then transfer it over to your Ubuntu box.
>
> Now in your Ubuntu Box [computer] please make your way to your Home folder.
>
> Once you are at your home folder right click on your home folder and make a
> new folder and call it wireless.
>
> Now that you have made a new folder called wireless in your home directory,
> it is time to move the downloaded file into the new folder called wireless.
>
> Move The Wireless Folder To The Firmware Directory
>
> sudo cp -r ~/wireless/* /lib/firmware/
>
> Now let's double check to make sure the download made it to the firmware
> directory. To do this type this into the terminal:
>
> ls /lib/firmware
>
> Ok so now that the download is in the firmware directory we need to go to
> that directory. To go there open your terminal and type in:
>
> cd /lib/firmware
>
> Now that you have changed directories let's double check to make sure you
> are in the right directory, this next code tells us where we are in the
> computer file directory. This next code stands for "print working
> directory".
>
> pwd
>
> Are you at /lib/firmware if so good if not go back one step.
>
> Now that we are in the firmware directory. We have to extract the download,
> to do this type in:
>
> sudo -s
>
> Then enter your password then:
>
> tar xvf b43-all-fw.tar_.gz
>
> Now is the firmware extracted properly? check by typing:
>
> ls /lib/firmware/b43
>
> or:
>
> ls /lib/firmware/b43legacy
>
> Do you see the ucode files? if so then delete the gz file:
>
> sudo rm *.gz
>
> Then:
>
> exit
>
> Reboot

No, I do not know where that file is found. Even if I knew of such a file, 
Broadcom has expressly declined to provide that firmware for redistribution. 
Posting such a file could invite legal action. If someone else has violated 
Broadcom's directive, I would not facilitate that violation.

Rather than doing that, the link at 
http://wireless.kernel.org/en/users/Drivers/b43#firmwareinstallation shows what 
to do for Ubuntu installations. Follow those instructions - they refer to a 
legal way to get the firmware. I would have thought that asking this question on 
an Ubuntu Forum would have been more productive.

By the way, piggybacking your request on this thread is very bad netiquette. You 
should not have done a "reply-to".

Larry
