From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: net 2.6.25 is broken when building with wireless/iwlwifi
Date: Sun, 20 Jan 2008 14:23:15 -0500
Message-ID: <47939FA3.5040401@garzik.org>
References: <d0383f90801200601y71472ae6ha638c1567d4abde4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ian Brown <ianbrn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <d0383f90801200601y71472ae6ha638c1567d4abde4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ian Brown wrote:
> Hello,
> net 2.6.25 is broken when building with the wireless/iwlwifi
> subtree;  we get the following errors (we noticed that iwl_down() and
> iwl_resume()
> implementation do exist in garzik tree, but there are more differences
> so a simple
> patch with only adding these two methods might be risky)
> 
> ...
> ...
> 
>   CHK     include/linux/version.h
>   CHK     include/linux/utsrelease.h
>   CALL    scripts/checksyscalls.sh
>   CHK     include/linux/compile.h
>   CC [M]  drivers/net/wireless/iwlwifi/iwl3945-base.o
> drivers/net/wireless/iwlwifi/iwl3945-base.c: In function 'iwl3945_pci_remove':
> drivers/net/wireless/iwlwifi/iwl3945-base.c:8639: error: implicit
> declaration of function 'iwl_down'
> drivers/net/wireless/iwlwifi/iwl3945-base.c: In function 'iwl3945_pci_resume':
> drivers/net/wireless/iwlwifi/iwl3945-base.c:8779: error: implicit
> declaration of function 'iwl_resume'
> make[4]: *** [drivers/net/wireless/iwlwifi/iwl3945-base.o] Error 1
> make[3]: *** [drivers/net/wireless/iwlwifi] Error 2
> make[2]: *** [drivers/net/wireless] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2

hrm, that sounds like a potential mis-merge on my part (though 
ultimately linville should be re-syncing with net-2.6.25 soon anyway)

	Jeff
