From: David Binderman <linuxdev.baldrick@gmail.com>
Subject: linux-4.7-rc2/drivers/net/fjes/fjes_main.c:1346]: (style) Redundant condition
Date: Tue, 7 Jun 2016 10:46:41 +0100
Message-ID: <CAMzoamamjOZPS2PT8BAR7KG5re4nCKDb6Yew3NtQ+=oDRApeww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dcb314@hotmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello there,

linux-4.7-rc2/drivers/net/fjes/fjes_main.c:1346]: (style) Redundant
condition: !is_shared. 'is_shared && (!is_shared || !stop_req_done)'
is equivalent to 'is_shared && !stop_req_done'

Source code is

            if ((!stop_req ||
                 (is_shared && (!is_shared || !stop_req_done))) &&
                (is_shared || !unshare_watch || !unshare_reserve))

          if ((!stop_req ||
                 (is_shared && !stop_req_done)) &&
                (is_shared || !unshare_watch || !unshare_reserve))

Also in the same file:

[drivers/net/fjes/fjes_main.c:1321]: (style) Variable 'max_epid' is
assigned a value that is never used.
[drivers/net/fjes/fjes_main.c:1320]: (style) Variable 'my_epid' is
assigned a value that is never used.

These two might be candidates for deletion.

Regards

David Binderman
